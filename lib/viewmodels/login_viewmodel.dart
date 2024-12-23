import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository; // Bağımlılık
  bool isLoading = false; // Yükleme durumu
  String? errorMessage; // Hata mesajı

  // Constructor: AuthRepository zorunlu olarak sağlanmalı
  LoginViewModel(this._authRepository);

  // Kullanıcı giriş işlemi
  Future<UserModel?> login(String username, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners(); // UI'yi bilgilendir

      // AuthRepository üzerinden login işlemi
      final user = await _authRepository.login(username, password);

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
}
