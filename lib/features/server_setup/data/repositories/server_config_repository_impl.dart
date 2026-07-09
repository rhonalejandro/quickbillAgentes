import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/server_config.dart';
import '../../domain/repositories/server_config_repository.dart';

class ServerConfigRepositoryImpl implements ServerConfigRepository {
  const ServerConfigRepositoryImpl(this._storage);

  final SecureStorage _storage;

  @override
  Future<ServerConfig?> getConfig() async {
    final host = await _storage.getHost();
    if (host == null || host.isEmpty) {
      return null;
    }
    return ServerConfig(
      host: host,
      headerName: await _storage.getHeaderName(),
      headerValue: await _storage.getHeaderValue(),
      userAgent: await _storage.getUserAgent(),
    );
  }

  @override
  Future<void> saveConfig(ServerConfig config) async {
    await _storage.saveHost(config.host);
    await _storage.saveHeaderName(config.headerName);
    await _storage.saveHeaderValue(config.headerValue);
    await _storage.saveUserAgent(config.userAgent);
  }

  @override
  Future<void> clearConfig() => _storage.clear();
}
