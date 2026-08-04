import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ApiConfig {
  // Override at build/run time: flutter run --dart-define=API_BASE_URL=https://your-app.vercel.app/api
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    // Local dev fallback. The Android emulator can't reach the host's
    // "localhost" directly — it's reachable at 10.0.2.2 instead.
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:4000/api';
    return 'http://localhost:4000/api';
  }
}

/// Mirrors admin.js's api() helper: injects the bearer token, parses JSON,
/// and throws with the server's own error message on non-2xx responses.
class ApiClient {
  final AuthStorage _authStorage;
  ApiClient(this._authStorage);

  Future<Map<String, String>> _headers({bool json = true}) async {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    final token = await _authStorage.readToken();
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  dynamic _decode(http.Response res) {
    dynamic data;
    try {
      data = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    } catch (_) {
      data = null;
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final message = (data is Map && data['error'] is String) ? data['error'] as String : 'Xatolik (${res.statusCode})';
      throw ApiException(message, res.statusCode);
    }
    return data;
  }

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<dynamic> get(String path) async {
    final res = await http.get(_uri(path), headers: await _headers());
    return _decode(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final res = await http.post(_uri(path), headers: await _headers(), body: body != null ? jsonEncode(body) : null);
    return _decode(res);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final res = await http.put(_uri(path), headers: await _headers(), body: body != null ? jsonEncode(body) : null);
    return _decode(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await http.delete(_uri(path), headers: await _headers());
    return _decode(res);
  }
}
