import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripaz_app/viewmodels/detail_tour_view_model.dart';
import 'package:tripaz_app/viewmodels/home_view_model.dart';
import 'package:tripaz_app/widgets/bottom_navigation_bar.dart';
import 'repositories/main_repository.dart';
import 'services/main_api_service.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/wish_list_view_model.dart';
import 'views/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // AuthService sağlayıcısı
        Provider(create: (_) => MainApiService()),

        // AuthRepository, AuthService'e bağımlı
        ProxyProvider<MainApiService, MainRepository>(
          update: (_, mainApiService, __) => MainRepository(mainApiService),
        ),

        // LoginViewModel, AuthRepository'ye bağımlı
        ChangeNotifierProxyProvider<MainRepository, LoginViewModel>(
          create: (_) =>
              LoginViewModel(MainRepository(MainApiService())), // İlk başlatma
          update: (_, authRepository, __) => LoginViewModel(authRepository),
        ),

        // HomeViewModel'in eklenmesi
        ChangeNotifierProxyProvider<MainRepository, HomeViewModel>(
          create: (_) => HomeViewModel(MainRepository(MainApiService())),
          update: (_, mainRepository, __) => HomeViewModel(mainRepository),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              DetailTourViewModel(MainRepository(MainApiService())),
        ),
        ChangeNotifierProxyProvider<MainRepository, WishlistViewModel>(
          create: (context) => WishlistViewModel(
            Provider.of<MainRepository>(context, listen: false),
          ),
          update: (context, mainRepo, previousWishlistViewModel) =>
              previousWishlistViewModel ??
              WishlistViewModel(
                Provider.of<MainRepository>(context, listen: false),
              ),
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
      home: const LoginScreen(),
    );
  }
}
