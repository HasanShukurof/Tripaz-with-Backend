import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripaz_app/viewmodels/detail_tour_view_model.dart';
import 'package:tripaz_app/viewmodels/home_view_model.dart';
import 'firebase_options.dart';
import 'repositories/main_repository.dart';
import 'services/main_api_service.dart';
import 'services/cache_service.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/wish_list_view_model.dart';
import 'views/login_screen.dart';
import 'viewmodels/detail_booking_view_model.dart';
import 'viewmodels/booking_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/onboarding_screen.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'viewmodels/payment_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter binding'i başlat

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Uygulamayı başlatırken önbelleği temizle
  final cacheService = CacheService();
  cacheService.clearAllCache().then((_) {
    print('Uygulama başlangıcında önbellek temizlendi');

    runApp(
      MultiProvider(
        providers: [
          // API ve Cache Servisleri
          Provider(create: (_) => MainApiService()),
          Provider(create: (_) => CacheService()),

          // MainRepository, servislerine bağımlı
          ProxyProvider2<MainApiService, CacheService, MainRepository>(
            update: (_, mainApiService, cacheService, __) =>
                MainRepository(mainApiService, cacheService),
          ),

          // LoginViewModel, MainRepository'ye bağımlı
          ChangeNotifierProxyProvider<MainRepository, LoginViewModel>(
            create: (_) => LoginViewModel(
                MainRepository(MainApiService(), CacheService())),
            update: (_, mainRepository, __) => LoginViewModel(mainRepository),
          ),

          // HomeViewModel'in eklenmesi
          ChangeNotifierProxyProvider<MainRepository, HomeViewModel>(
            create: (_) =>
                HomeViewModel(MainRepository(MainApiService(), CacheService())),
            update: (_, mainRepository, __) => HomeViewModel(mainRepository),
          ),
          ChangeNotifierProvider(
            create: (context) => DetailTourViewModel(MainRepository(
                MainApiService(),
                Provider.of<CacheService>(context, listen: false))),
          ),
          ChangeNotifierProxyProvider<MainRepository, DetailBookingViewModel>(
            create: (context) => DetailBookingViewModel(
              Provider.of<MainRepository>(context, listen: false),
            ),
            update: (context, mainRepo, previousDetailBookingViewModel) =>
                previousDetailBookingViewModel ??
                DetailBookingViewModel(
                  Provider.of<MainRepository>(context, listen: false),
                ),
          ),
          ChangeNotifierProxyProvider<MainRepository, BookingViewModel>(
            create: (context) => BookingViewModel(
              Provider.of<MainRepository>(context, listen: false),
            ),
            update: (context, mainRepo, previousBookingViewModel) =>
                previousBookingViewModel ??
                BookingViewModel(
                  Provider.of<MainRepository>(context, listen: false),
                ),
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
          ChangeNotifierProxyProvider<MainRepository, PaymentViewModel>(
            create: (_) => PaymentViewModel(
                MainRepository(MainApiService(), CacheService())),
            update: (_, mainRepo, __) => PaymentViewModel(mainRepo),
          ),
        ],
        child: const TripazApp(),
      ),
    );
  });
}

class TripazApp extends StatelessWidget {
  const TripazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future:
          checkLoginStatus(), // Hem onboarding hem login durumunu kontrol et
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Tripaz App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: snapshot.data == true
              ? const BottomNavBar() // Kullanıcı giriş yapmışsa
              : FutureBuilder<bool>(
                  // Yapmamışsa onboarding kontrolü
                  future: checkOnboardingStatus(),
                  builder: (context, onboardingSnapshot) {
                    if (onboardingSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return onboardingSnapshot.data == true
                        ? const LoginScreen() // Onboarding tamamlanmışsa artık LoginScreen'e yönlendir
                        : const OnboardingScreen();
                  },
                ),
        );
      },
    );
  }

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null;
  }

  Future<bool> checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }
}
