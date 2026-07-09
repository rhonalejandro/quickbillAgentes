import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/repositories/server_config_repository_impl.dart';
import '../../domain/entities/server_config.dart';
import '../../domain/repositories/server_config_repository.dart';

final serverConfigRepositoryProvider = Provider<ServerConfigRepository>((ref) {
  return ServerConfigRepositoryImpl(ref.read(secureStorageProvider));
});

class ServerConfigNotifier extends AsyncNotifier<ServerConfig?> {
  @override
  Future<ServerConfig?> build() async {
    return ref.read(serverConfigRepositoryProvider).getConfig();
  }

  Future<void> save(ServerConfig config) async {
    await ref.read(serverConfigRepositoryProvider).saveConfig(config);
    state = AsyncData(config);
  }

  Future<void> clear() async {
    await ref.read(serverConfigRepositoryProvider).clearConfig();
    state = const AsyncData(null);
  }
}

final serverConfigProvider =
    AsyncNotifierProvider<ServerConfigNotifier, ServerConfig?>(
  ServerConfigNotifier.new,
);
