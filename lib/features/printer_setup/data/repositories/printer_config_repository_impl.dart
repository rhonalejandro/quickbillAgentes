import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/printer_config.dart';
import '../../domain/repositories/printer_config_repository.dart';

class PrinterConfigRepositoryImpl implements PrinterConfigRepository {
  const PrinterConfigRepositoryImpl(this._storage);

  final SecureStorage _storage;

  @override
  Future<PrinterConfig?> get() async {
    final typeStr = await _storage.getPrinterType();
    if (typeStr == null) return null;

    final type = PrinterType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => PrinterType.network,
    );

    final ip = await _storage.getPrinterIp();
    final portStr = await _storage.getPrinterPort();
    final name = await _storage.getPrinterName();

    return PrinterConfig(
      type: type,
      ip: ip,
      port: int.tryParse(portStr ?? '9100') ?? 9100,
      printerName: name,
    );
  }

  @override
  Future<void> save(PrinterConfig config) async {
    await _storage.savePrinterType(config.type.name);
    if (config.ip != null) await _storage.savePrinterIp(config.ip!);
    await _storage.savePrinterPort(config.port.toString());
    if (config.printerName != null) {
      await _storage.savePrinterName(config.printerName!);
    }
  }

  @override
  Future<void> clear() => _storage.clearPrinter();
}
