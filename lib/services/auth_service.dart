import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _role = 'guest';

  bool get isLoggedIn => _isLoggedIn;
  String get role => _role;

  void login(String selectedRole) {
    _isLoggedIn = true;
    _role = selectedRole;
    notifyListeners(); 
  }

  void logout() {
    _isLoggedIn = false;
    _role = 'guest';
    notifyListeners();
  }
}