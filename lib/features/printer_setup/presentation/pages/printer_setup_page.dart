import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/printer/printer_discovery_service.dart';
import '../../../../core/printer/printer_service.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../domain/entities/printer_config.dart';
import '../providers/printer_config_provider.dart';
import '../widgets/network_printer_form.dart';
import '../widgets/printer_type_selector.dart';
import '../widgets/usb_printer_selector.dart';

class PrinterSetupPage extends ConsumerStatefulWidget {
  const PrinterSetupPage({super.key});

  @override
  ConsumerState<PrinterSetupPage> createState() => _PrinterSetupPageState();
}

class _PrinterSetupPageState extends ConsumerState<PrinterSetupPage> {
  final _networkFormKey = GlobalKey<FormState>();
  final _usbFormKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController(text: '9100');

  PrinterType _type = PrinterType.network;
  String? _selectedPrinter;
  List<String> _printers = [];
  bool _loadingPrinters = false;
  bool _saving = false;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
    _loadPrinters();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final config = await ref.read(printerConfigProvider.future);
    if (config == null) return;
    setState(() {
      _type = config.type;
      _ipController.text = config.ip ?? '';
      _portController.text = config.port.toString();
      _selectedPrinter = config.printerName;
    });
  }

  Future<void> _loadPrinters() async {
    setState(() => _loadingPrinters = true);
    final list = await ref.read(printerDiscoveryServiceProvider).getInstalledPrinters();
    setState(() {
      _printers = list;
      _loadingPrinters = false;
    });
  }

  Future<void> _save() async {
    final config = _buildConfig();
    if (config == null) return;
    setState(() => _saving = true);
    await ref.read(printerConfigProvider.notifier).save(config);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.printerSaveSuccess)),
      );
      context.pop();
    }
  }

  Future<void> _testPrint() async {
    final config = _buildConfig();
    if (config == null) return;

    log('[PrinterSetup] ▶️ Imprimir prueba presionado');
    log('[PrinterSetup] Config: type=${config.type}, ip=${config.ip}, port=${config.port}, name=${config.printerName}');

    setState(() => _testing = true);
    try {
      // ESC/POS test: initialize + text + cut
      final testData = Uint8List.fromList([
        0x1B, 0x40,                     // ESC @ (init)
        0x1B, 0x61, 0x01,               // center
        ...('POS QB - Prueba\n\n\n').codeUnits,
        0x1D, 0x56, 0x42, 0x00,         // cut
      ]);
      log('[PrinterSetup] Enviando ${testData.length} bytes a printRaw...');
      await ref.read(printerServiceProvider).printRaw(config, testData);
      log('[PrinterSetup] ✅ printRaw completado exitosamente');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.printerTestSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.printerError}$e')),
        );
      }
    } finally {
      setState(() => _testing = false);
    }
  }

  PrinterConfig? _buildConfig() {
    if (_type == PrinterType.network) {
      if (!(_networkFormKey.currentState?.validate() ?? false)) return null;
      return PrinterConfig(
        type: PrinterType.network,
        ip: _ipController.text.trim(),
        port: int.tryParse(_portController.text.trim()) ?? 9100,
      );
    } else {
      if (!(_usbFormKey.currentState?.validate() ?? false)) return null;
      return PrinterConfig(
        type: PrinterType.windowsUsb,
        printerName: _selectedPrinter,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.printerSetupTitle, style: AppTextStyles.titleLarge),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppDimensions.formMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrinterTypeSelector(
                  selected: _type,
                  onChanged: (t) => setState(() => _type = t),
                ),
                const SizedBox(height: AppDimensions.lg),
                if (_type == PrinterType.network)
                  NetworkPrinterForm(
                    ipController: _ipController,
                    portController: _portController,
                    formKey: _networkFormKey,
                  )
                else
                  Form(
                    key: _usbFormKey,
                    child: UsbPrinterSelector(
                      printers: _printers,
                      selected: _selectedPrinter,
                      isLoading: _loadingPrinters,
                      onChanged: (v) => setState(() => _selectedPrinter = v),
                    ),
                  ),
                const SizedBox(height: AppDimensions.xl),
                PrimaryButton(
                  label: AppStrings.printerSaveButton,
                  onPressed: _save,
                  isLoading: _saving,
                ),
                const SizedBox(height: AppDimensions.sm),
                OutlinedButton(
                  onPressed: _testing ? null : _testPrint,
                  child: _testing
                      ? const SizedBox(
                          height: AppDimensions.iconMd,
                          width: AppDimensions.iconMd,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Text(AppStrings.printerTestButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
