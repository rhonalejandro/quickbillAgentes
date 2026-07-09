import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final printerDiscoveryServiceProvider =
    Provider<PrinterDiscoveryService>((_) => PrinterDiscoveryService());

class PrinterDiscoveryService {
  Future<List<String>> getInstalledPrinters() async {
    final result = await Process.run(
      'powershell',
      ['-Command', 'Get-Printer | Select-Object -ExpandProperty Name'],
      runInShell: true,
    );

    if (result.exitCode != 0) return [];

    return (result.stdout as String)
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
