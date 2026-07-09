import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyHost = 'agent_host';
  static const _keyHeaderName = 'agent_header_name';
  static const _keyHeaderValue = 'agent_header_value';
  static const _keyUserAgent = 'agent_user_agent';
  static const _keyPrinterType = 'printer_type';
  static const _keyPrinterIp = 'printer_ip';
  static const _keyPrinterPort = 'printer_port';
  static const _keyPrinterName = 'printer_name';

  Future<String?> getHost() => _storage.read(key: _keyHost);
  Future<String?> getHeaderName() => _storage.read(key: _keyHeaderName);
  Future<String?> getHeaderValue() => _storage.read(key: _keyHeaderValue);
  Future<String?> getUserAgent() => _storage.read(key: _keyUserAgent);

  Future<void> saveHost(String host) => _storage.write(key: _keyHost, value: host);
  Future<void> saveHeaderName(String? value) =>
      _storage.write(key: _keyHeaderName, value: value);
  Future<void> saveHeaderValue(String? value) =>
      _storage.write(key: _keyHeaderValue, value: value);
  Future<void> saveUserAgent(String? value) =>
      _storage.write(key: _keyUserAgent, value: value);

  Future<void> clear() async {
    await _storage.delete(key: _keyHost);
    await _storage.delete(key: _keyHeaderName);
    await _storage.delete(key: _keyHeaderValue);
    await _storage.delete(key: _keyUserAgent);
  }

  // Printer
  Future<String?> getPrinterType() => _storage.read(key: _keyPrinterType);
  Future<String?> getPrinterIp() => _storage.read(key: _keyPrinterIp);
  Future<String?> getPrinterPort() => _storage.read(key: _keyPrinterPort);
  Future<String?> getPrinterName() => _storage.read(key: _keyPrinterName);

  Future<void> savePrinterType(String type) =>
      _storage.write(key: _keyPrinterType, value: type);
  Future<void> savePrinterIp(String ip) =>
      _storage.write(key: _keyPrinterIp, value: ip);
  Future<void> savePrinterPort(String port) =>
      _storage.write(key: _keyPrinterPort, value: port);
  Future<void> savePrinterName(String name) =>
      _storage.write(key: _keyPrinterName, value: name);

  Future<void> clearPrinter() async {
    await _storage.delete(key: _keyPrinterType);
    await _storage.delete(key: _keyPrinterIp);
    await _storage.delete(key: _keyPrinterPort);
    await _storage.delete(key: _keyPrinterName);
  }
}
