import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Mirrors admin.js's localStorage.getItem('admin_token') / setItem, but
/// backed by the platform keychain/keystore instead of plain storage.
class AuthStorage {
  static const _tokenKey = 'admin_token';
  final _storage = const FlutterSecureStorage();

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> writeToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
