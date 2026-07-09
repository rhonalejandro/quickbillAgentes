import '../entities/server_config.dart';

abstract interface class ServerConfigRepository {
  Future<ServerConfig?> getConfig();
  Future<void> saveConfig(ServerConfig config);
  Future<void> clearConfig();
}
