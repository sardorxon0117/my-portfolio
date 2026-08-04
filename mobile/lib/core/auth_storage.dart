import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Mirrors admin.js's localStorage.getItem('admin_token') / setItem, but
/// backed by the platform keychain/keystore instead of plain storage.
class AuthStorage {
  static const _tokenKey = 'admin_token';

  // On macOS, the default "Data Protection Keychain" backing throws
  // PlatformException(-34018, "A required entitlement is not present")
  // under App Sandbox unless the app is signed with a real Team ID and a
  // matching keychain-access-groups entitlement. Falling back to the
  // regular (non-data-protection) Keychain avoids that requirement — it's
  // the fix flutter_secure_storage's own docs recommend for this error.
  static const _macOptions = MacOsOptions(useDataProtectionKeyChain: false);

  final _storage = const FlutterSecureStorage();

  Future<String?> readToken() => _storage.read(key: _tokenKey, mOptions: _macOptions);

  Future<void> writeToken(String token) => _storage.write(key: _tokenKey, value: token, mOptions: _macOptions);

  Future<void> clearToken() => _storage.delete(key: _tokenKey, mOptions: _macOptions);
}
