import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';

import '../../../../core/printer/printer_service.dart';
import '../../../../routes/app_router.dart';
import '../../../printer_setup/presentation/providers/printer_config_provider.dart';
import '../../../server_setup/presentation/providers/server_config_provider.dart';
import '../providers/agent_viewer_provider.dart';
import '../widgets/agent_error_widget.dart';
import '../widgets/settings_fab.dart';

class AgentViewerPage extends ConsumerStatefulWidget {
  const AgentViewerPage({super.key});

  @override
  ConsumerState<AgentViewerPage> createState() => _AgentViewerPageState();
}

class _AgentViewerPageState extends ConsumerState<AgentViewerPage> {
  bool _showFab = false;

  void _updateFabVisibility(PointerEvent event) {
    final shouldShow = event.localPosition.dy < 80;
    if (_showFab != shouldShow) {
      setState(() => _showFab = shouldShow);
    }
  }

  void _hideFab() => setState(() => _showFab = false);

  Future<void> _toggleFullScreen() async {
    final isFullScreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFullScreen);
  }

  Future<void> _reconfigure() async {
    if (mounted) context.go(AppRoutes.setup);
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (_) => _SettingsDialog(
        onReconfigure: () {
          Navigator.pop(context);
          _reconfigure();
        },
        onConfigurePrinter: () {
          Navigator.pop(context);
          context.push(AppRoutes.printerSetup);
        },
      ),
    );
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: 'toggleFullScreen',
      callback: (_) => _toggleFullScreen(),
    );
    controller.addJavaScriptHandler(
      handlerName: 'print',
      callback: (args) => _handlePrint(args),
    );
  }

  Future<void> _handlePrint(List<dynamic> args) async {
    final config = await ref.read(printerConfigProvider.future);

    if (config == null) {
      if (mounted) _showNoPrinterDialog();
      return;
    }

    try {
      final base64Data = args.isNotEmpty ? args[0] as String : '';
      final bytes = base64Decode(base64Data);
      await ref.read(printerServiceProvider).printRaw(config, Uint8List.fromList(bytes));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.printerError}$e')),
        );
      }
    }
  }

  void _showNoPrinterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.noPrinterTitle, style: AppTextStyles.titleLarge),
        content: Text(AppStrings.noPrinterBody, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(AppRoutes.printerSetup);
            },
            child: Text(
              AppStrings.noPrinterAction,
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _injectShortcutBridge(InAppWebViewController controller) async {
    await controller.evaluateJavascript(source: '''
      (function() {
        if (window.__agentesBridgeInjected) return;
        window.__agentesBridgeInjected = true;

        document.addEventListener('keydown', function(e) {
          if (e.key === 'F11') {
            e.preventDefault();
            window.flutter_inappwebview.callHandler('toggleFullScreen');
          }
        }, true);

        document.addEventListener('wheel', function(e) {
          if (e.ctrlKey) return;
          var el = document.elementFromPoint(e.clientX, e.clientY);
          while (el && el !== document.body && el !== document.documentElement) {
            var style = window.getComputedStyle(el);
            var canScroll = (style.overflowY === 'auto' || style.overflowY === 'scroll') &&
                            el.scrollHeight > el.clientHeight;
            if (canScroll) {
              el.scrollTop += e.deltaY;
              e.preventDefault();
              return;
            }
            el = el.parentElement;
          }
          window.scrollBy(0, e.deltaY);
          e.preventDefault();
        }, { passive: false });
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agentViewerProvider);
    final config = ref.watch(serverConfigProvider).valueOrNull;

    if (config == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.go(AppRoutes.setup),
      );
      return const Scaffold(body: SizedBox.shrink());
    }

    if (state.status == AgentViewerStatus.error) {
      return Scaffold(body: AgentErrorWidget(onReconfigure: _reconfigure));
    }

    return Scaffold(
      body: MouseRegion(
        onHover: _updateFabVisibility,
        onExit: (_) => _hideFab(),
        child: Stack(
          children: [
            InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(config.agentUrl),
              headers: {
                'sec-ch-ua': '"Chromium";v="136", "Not.A/Brand";v="8"',
                'sec-ch-ua-mobile': '?0',
                'sec-ch-ua-platform': '"Windows"',
                config.effectiveHeaderName: config.effectiveHeaderValue,
              },
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              databaseEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              javaScriptCanOpenWindowsAutomatically: true,
              userAgent: config.effectiveUserAgent,
            ),
            onWebViewCreated: _onWebViewCreated,
            onLoadStart: (c, url) =>
                ref.read(agentViewerProvider.notifier).onPageStarted(),
            onLoadStop: (c, url) async {
              ref.read(agentViewerProvider.notifier).onPageFinished();
              await _injectShortcutBridge(c);
            },
            onReceivedHttpError: (c, request, errorResponse) =>
                ref.read(agentViewerProvider.notifier).onHttpError(errorResponse.statusCode),
            onReceivedError: (c, request, error) =>
                ref.read(agentViewerProvider.notifier).onNetworkError(),
          ),
          if (state.status == AgentViewerStatus.loading)
            const SizedBox.expand(
              child: ColoredBox(
                color: AppColors.surface,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: IgnorePointer(
                ignoring: !_showFab,
                child: AnimatedOpacity(
                  opacity: _showFab ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: SettingsFab(onPressed: _openSettings),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _SettingsDialog extends StatelessWidget {
  const _SettingsDialog({
    required this.onReconfigure,
    required this.onConfigurePrinter,
  });

  final VoidCallback onReconfigure;
  final VoidCallback onConfigurePrinter;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ajustes',
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.lg),
              _SettingsTile(
                icon: Icons.dns_rounded,
                label: AppStrings.settingsReconfigure,
                onTap: onReconfigure,
              ),
              const SizedBox(height: AppDimensions.sm),
              _SettingsTile(
                icon: Icons.print_rounded,
                label: AppStrings.settingsConfigurePrinter,
                onTap: onConfigurePrinter,
              ),
              const SizedBox(height: AppDimensions.md),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm + AppDimensions.xs,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: AppDimensions.iconMd),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Text(label, style: AppTextStyles.bodyLarge),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: AppDimensions.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
