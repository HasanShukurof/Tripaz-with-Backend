import 'package:flutter/material.dart';
import '../models/user_login_model.dart';
import '../repositories/main_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final MainRepository _repo; // Bağımlılık
  bool isLoading = false; // Yükleme durumu
  String? errorMessage; // Hata mesajı

  // Constructor: AuthRepository zorunlu olarak sağlanmalı
  LoginViewModel(this._repo);

  // Kullanıcı giriş işlemi
  Future<UserLoginModel?> login(String username, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners(); // UI'yi bilgilendir

      // AuthRepository üzerinden login işlemi
      final user = await _repo.login(username, password);

      isLoading = false;
      notifyListeners();

      return user; // Başarılıysa kullanıcı modelini döndür
    } catch (e) {
      // Hata durumu
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();

      return null;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _repo.register(
        username: username,
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
