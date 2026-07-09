import 'package:equatable/equatable.dart';

enum PrinterType { network, windowsUsb }

class PrinterConfig extends Equatable {
  const PrinterConfig({
    required this.type,
    this.ip,
    this.port = 9100,
    this.printerName,
  });

  final PrinterType type;
  final String? ip;
  final int port;
  final String? printerName;

  @override
  List<Object?> get props => [type, ip, port, printerName];
}
