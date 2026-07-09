import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../data/repositories/printer_config_repository_impl.dart';
import '../../domain/entities/printer_config.dart';
import '../../domain/repositories/printer_config_repository.dart';

final _printerRepoProvider = Provider<PrinterConfigRepository>((ref) {
  return PrinterConfigRepositoryImpl(ref.read(secureStorageProvider));
});

class PrinterConfigNotifier extends AsyncNotifier<PrinterConfig?> {
  @override
  Future<PrinterConfig?> build() async {
    return ref.read(_printerRepoProvider).get();
  }

  Future<void> save(PrinterConfig config) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_printerRepoProvider).save(config);
      return config;
    });
  }

  Future<void> clear() async {
    await ref.read(_printerRepoProvider).clear();
    state = const AsyncData(null);
  }
}

final printerConfigProvider =
    AsyncNotifierProvider<PrinterConfigNotifier, PrinterConfig?>(
  PrinterConfigNotifier.new,
);
