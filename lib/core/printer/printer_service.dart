import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:win32/win32.dart';

import '../../features/printer_setup/domain/entities/printer_config.dart';

final printerServiceProvider = Provider<PrinterService>((_) => PrinterService());

class PrinterService {
  Future<void> printRaw(PrinterConfig config, Uint8List data) async {
    log('[PrinterService] printRaw iniciado | type=${config.type} | bytes=${data.length}');
    try {
      switch (config.type) {
        case PrinterType.network:
          await _printNetwork(config, data);
        case PrinterType.windowsUsb:
          await _printWindowsUsb(config, data);
      }
      log('[PrinterService] printRaw finalizado OK');
    } catch (e, st) {
      log('[PrinterService] ❌ printRaw falló: $e');
      log('[PrinterService] StackTrace: $st');
      rethrow;
    }
  }

  Future<void> _printNetwork(PrinterConfig config, Uint8List data) async {
    log('[PrinterService] _printNetwork → ${config.ip}:${config.port}');

    if (config.ip == null || config.ip!.isEmpty) {
      throw Exception('La dirección IP de la impresora no está configurada.');
    }
    if (config.port <= 0 || config.port > 65535) {
      throw Exception('El puerto de la impresora no es válido (${config.port}).');
    }

    Socket? socket;
    try {
      log('[PrinterService] Intentando Socket.connect(${config.ip}, ${config.port})...');
      socket = await Socket.connect(
        config.ip!,
        config.port,
        timeout: const Duration(seconds: 10),
      );
      log('[PrinterService] ✅ Socket conectado (local=${socket.address}:${socket.port})');

      socket.add(data);
      log('[PrinterService] Datos agregados al socket (${data.length} bytes)');

      await socket.flush();
      log('[PrinterService] ✅ Flush completado');

      await socket.close();
      log('[PrinterService] ✅ Socket cerrado correctamente');
    } on SocketException catch (e) {
      log('[PrinterService] ❌ SocketException: ${e.message} | osError=${e.osError} | address=${e.address} | port=${e.port}');
      throw Exception(
        'No se pudo conectar o enviar datos a la impresora de red '
        '(${config.ip}:${config.port}). Verifique que la impresora esté encendida, '
        'en la misma red y que el puerto ${config.port} esté abierto. Error: ${e.message}',
      );
    } catch (e, st) {
      log('[PrinterService] ❌ Error inesperado en _printNetwork: $e');
      log('[PrinterService] StackTrace: $st');
      throw Exception('Error inesperado al imprimir por red: $e');
    } finally {
      if (socket != null) {
        log('[PrinterService] Destroying socket...');
        socket.destroy();
      }
    }
  }

  Future<void> _printWindowsUsb(PrinterConfig config, Uint8List data) async {
    final pName = config.printerName!.toNativeUtf16();
    final phPrinter = calloc<HANDLE>();

    try {
      if (OpenPrinter(pName, phPrinter, nullptr) == FALSE) {
        throw Exception('No se pudo abrir: ${config.printerName}');
      }

      final docName = 'POS'.toNativeUtf16();
      final rawType = 'RAW'.toNativeUtf16();
      final docInfo = calloc<DOC_INFO_1>()
        ..ref.pDocName = docName
        ..ref.pDatatype = rawType
        ..ref.pOutputFile = nullptr;

      try {
        if (StartDocPrinter(phPrinter.value, 1, docInfo.cast()) == 0) {
          throw Exception('Error al iniciar documento de impresión');
        }
        StartPagePrinter(phPrinter.value);

        final pData = calloc<Uint8>(data.length);
        pData.asTypedList(data.length).setAll(0, data);
        final written = calloc<DWORD>();

        try {
          WritePrinter(phPrinter.value, pData, data.length, written);
        } finally {
          calloc.free(pData);
          calloc.free(written);
        }

        EndPagePrinter(phPrinter.value);
        EndDocPrinter(phPrinter.value);
      } finally {
        calloc.free(docName);
        calloc.free(rawType);
        calloc.free(docInfo);
        ClosePrinter(phPrinter.value);
      }
    } finally {
      calloc.free(pName);
      calloc.free(phPrinter);
    }
  }
}
