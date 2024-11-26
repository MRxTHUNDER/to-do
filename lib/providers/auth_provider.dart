import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  bool _isAuthenticated = false;

  AuthProvider(this._prefs) {
    _isAuthenticated = _prefs.getBool('isAuthenticated') ?? false;
  }

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    // In a real app, implement actual authentication
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      await _prefs.setBool('isAuthenticated', true);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    await _prefs.setBool('isAuthenticated', false);
    notifyListeners();
  }

  Future<bool> register(String email, String password) async {
    // In a real app, implement actual registration
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      await _prefs.setBool('isAuthenticated', true);
      notifyListeners();
      return true;
    }
    return false;
  }
}
