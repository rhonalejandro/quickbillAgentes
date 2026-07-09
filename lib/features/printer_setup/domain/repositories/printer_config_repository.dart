import '../entities/printer_config.dart';

abstract interface class PrinterConfigRepository {
  Future<PrinterConfig?> get();
  Future<void> save(PrinterConfig config);
  Future<void> clear();
}
