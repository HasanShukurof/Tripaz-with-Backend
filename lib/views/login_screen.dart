import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'register_screen.dart';
import '../viewmodels/home_view_model.dart';
import 'empty_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final AuthService _authService = AuthService();

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Error',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);

    try {
      final user = await loginViewModel.login(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null && mounted) {
        final homeViewModel =
            Provider.of<HomeViewModel>(context, listen: false);
        await homeViewModel.loadUser();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
        );
      } else if (mounted) {
        String errorMessage = loginViewModel.errorMessage ?? 'Login failed.';
        errorMessage = errorMessage.replaceAll('Exception: ', '');
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        errorMessage = errorMessage.replaceAll('Exception: ', '');
        _showErrorDialog(errorMessage);
      }
    }
  }

  void _continueAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BottomNavBar()),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Yükleniyor..."),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: loginViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 60,
                            ),
                            const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextField(
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF94A3B8)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF94A3B8)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              keyboardType: TextInputType.visiblePassword,
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF94A3B8)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF94A3B8)),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0XFFF39C4FF),
                                ),
                                onPressed: _login,
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0XFFF39C4FF)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: _continueAsGuest,
                                child: const Text(
                                  "Continue as Guest",
                                  style: TextStyle(
                                    color: Color(0XFFF39C4FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen()),
                                );
                              },
                              child: const Text(
                                "Don't have an account? Register",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  // Yükleme göstergesini göster
                                  _showLoadingDialog();

                                  // Doğrudan Google API ile giriş yap (tek adımda)
                                  final userLoginModel =
                                      await _authService.signInWithGoogleApi();

                                  // Yükleme göstergesini kapat
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                  }

                                  if (userLoginModel == null) {
                                    throw Exception(
                                        'Oturum açma başarısız oldu.');
                                  }

                                  print('API Başarılı: Token alındı');

                                  // Token'ı SharedPreferences'a kaydet
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString('access_token',
                                      userLoginModel.accessToken);
                                  await prefs.setString('refresh_token',
                                      userLoginModel.refreshToken);

                                  // Kullanıcı artık oturum açtı olarak işaretle
                                  await prefs.setBool('is_logged_in', true);

                                  // Ana sayfaya yönlendir
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BottomNavBar(),
                                    ),
                                  );
                                } catch (e) {
                                  // Dialog'ları kapat (açık kalmışsa)
                                  if (mounted &&
                                      Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }

                                  if (mounted) {
                                    print('Google Sign In Hatası: $e');
                                    String errorMessage = e.toString();

                                    // Kullanıcı dostu hata mesajları
                                    if (errorMessage.contains('10:')) {
                                      errorMessage =
                                          'Google hizmetleriyle bağlantı sağlanamadı. Lütfen daha sonra tekrar deneyin.';
                                    } else if (errorMessage
                                        .contains('canceled')) {
                                      errorMessage =
                                          'Google ile giriş iptal edildi.';
                                    } else if (errorMessage
                                        .contains('network')) {
                                      errorMessage =
                                          'İnternet bağlantısı hatası. Lütfen bağlantınızı kontrol edin.';
                                    } else if (errorMessage
                                        .contains('Exception:')) {
                                      errorMessage = errorMessage
                                          .replaceAll('Exception:', '')
                                          .trim();
                                    }

                                    _showErrorDialog(errorMessage);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                side: const BorderSide(color: Colors.grey),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login),
                                  SizedBox(width: 8),
                                  Text("Google ile Giriş Yap"),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (Platform.isIOS)
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    // Yükleme göstergesini göster
                                    _showLoadingDialog();

                                    // Apple ile giriş yap ve token al
                                    final userLoginModel =
                                        await _authService.signInWithAppleApi();

                                    // Yükleme göstergesini kapat
                                    if (mounted) {
                                      Navigator.of(context).pop();
                                    }

                                    if (userLoginModel == null) {
                                      throw Exception(
                                          'Oturum açma başarısız oldu.');
                                    }

                                    print('API Başarılı: Apple Token alındı');

                                    // Token'ı SharedPreferences'a kaydet
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString('access_token',
                                        userLoginModel.accessToken);
                                    await prefs.setString('refresh_token',
                                        userLoginModel.refreshToken);

                                    // Kullanıcı artık oturum açtı olarak işaretle
                                    await prefs.setBool('is_logged_in', true);

                                    // Ana sayfaya yönlendir
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const BottomNavBar(),
                                      ),
                                    );
                                  } catch (e) {
                                    // Dialog'ları kapat (açık kalmışsa)
                                    if (mounted &&
                                        Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    }

                                    if (mounted) {
                                      print('Apple Sign In Hatası: $e');
                                      String errorMessage = e.toString();

                                      // Kullanıcı dostu hata mesajları
                                      if (errorMessage.contains('canceled')) {
                                        errorMessage =
                                            'Apple ile giriş iptal edildi.';
                                      } else if (errorMessage
                                          .contains('network')) {
                                        errorMessage =
                                            'İnternet bağlantısı hatası. Lütfen bağlantınızı kontrol edin.';
                                      } else if (errorMessage
                                          .contains('Exception:')) {
                                        errorMessage = errorMessage
                                            .replaceAll('Exception:', '')
                                            .trim();
                                      }

                                      _showErrorDialog(errorMessage);
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(color: Colors.grey),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.apple),
                                    SizedBox(width: 8),
                                    Text("Apple ile Giriş Yap"),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
