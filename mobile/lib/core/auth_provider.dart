import 'package:flutter/foundation.dart';
import 'auth_storage.dart';
import 'portfolio_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthStorage _storage;
  final PortfolioRepository _repo;
  AuthProvider(this._storage, this._repo);

  bool _isAuthenticated = false;
  bool _loading = true;
  bool get isAuthenticated => _isAuthenticated;
  bool get loading => _loading;

  Future<void> bootstrap() async {
    final token = await _storage.readToken();
    if (token == null) {
      _isAuthenticated = false;
      _loading = false;
      notifyListeners();
      return;
    }
    _isAuthenticated = await _repo.checkAuth();
    if (!_isAuthenticated) await _storage.clearToken();
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final token = await _repo.login(username, password);
    await _storage.writeToken(token);
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.clearToken();
    _isAuthenticated = false;
    notifyListeners();
  }
}
