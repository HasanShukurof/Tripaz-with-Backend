import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/auth_repository.dart';
import 'services/auth_service.dart';
import 'viewmodels/login_viewmodel.dart';
import 'views/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // AuthService sağlayıcısı
        Provider(create: (_) => AuthService()),

        // AuthRepository, AuthService'e bağımlı
        ProxyProvider<AuthService, AuthRepository>(
          update: (_, authService, __) => AuthRepository(authService),
        ),

        // LoginViewModel, AuthRepository'ye bağımlı
        ChangeNotifierProxyProvider<AuthRepository, LoginViewModel>(
          create: (_) =>
              LoginViewModel(AuthRepository(AuthService())), // İlk başlatma
          update: (_, authRepository, __) => LoginViewModel(authRepository),
        ),
      ],
      child: const TripazApp(),
    ),
  );
}

class TripazApp extends StatelessWidget {
  const TripazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'API Login Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
