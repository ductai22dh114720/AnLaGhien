// lib/shared/provider/user_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_dapm/shared/models/user_model.dart';
import 'package:flutter_dapm/shared/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  UserModel? _user;
  UserModel? get user => _user;

  bool get isAdmin => _user?.role == 'admin';

  Future<void> fetchUser() async {
    _user = await _userService.getUserProfile();
    notifyListeners();
  }

  // Hàm này sẽ được gọi từ login screen
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}