import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_login_model.dart';
import 'dart:io' show Platform, File;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:math';

class AuthService {
  // Platform bazlı Google Sign-In yapılandırması
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    // Platform bazlı Google Sign-In yapılandırması
    if (Platform.isAndroid) {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // Android için web client ID - Backend'in beklediği ID'yi kullan
        serverClientId:
            '22621409630-dd475rc31b05i1pvsudq8uje8bvugdes.apps.googleusercontent.com',
      );
    } else if (Platform.isIOS) {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
        // iOS için web client ID
        serverClientId:
            '22621409630-dd475rc31b05i1pvsudq8uje8bvugdes.apps.googleusercontent.com',
        // Tek adımda onay için ek parametreler
        signInOption: SignInOption.standard,
        forceCodeForRefreshToken: false,
      );
    } else {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
        serverClientId:
            '76238259895-8hlu73vmvkvooqc33r25d4ohsd434e19.apps.googleusercontent.com',
      );
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign In ve ID Token alma
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Google ile giriş yap
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign In işlemi iptal edildi');
      }

      // Google'dan kimlik doğrulama bilgilerini al
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase için kimlik bilgisi oluştur
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase ile giriş yap
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign In hatası: $e');
      throw Exception('Google Sign In başarısız: $e');
    }
  }

  // Backend ile entegrasyon için metod (Backend hazır olduğunda kullanılacak)
  Future<UserCredential> signInWithGoogleViaBackend() async {
    try {
      // 1. Google Sign In yap ve ID Token al
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign In işlemi iptal edildi');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Google ID Token alınamadı');
      }

      // 2. Backend'e ID Token gönder ve custom token al
      // NOT: Backend endpoint hazır olduğunda burası aktif edilecek
      /*
      final response = await http.post(
        Uri.parse('https://sizin-backend-url/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Backend authentication hatası: ${response.body}');
      }
      
      final data = jsonDecode(response.body);
      final customToken = data['customToken'];
      
      // 3. Custom token ile Firebase'e giriş yap
      return await _auth.signInWithCustomToken(customToken);
      */

      // Şimdilik doğrudan Firebase ile giriş yap
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign In (Backend) hatası: $e');
      throw Exception('Google Sign In (Backend) başarısız: $e');
    }
  }

  // JWT token içeriğini decode eden yardımcı metod
  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      String payload = parts[1];
      // Base64 padding düzeltmesi
      switch (payload.length % 4) {
        case 0:
          break; // Düzeltme gerekmez
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
        default:
          return null; // Geçersiz base64
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      print('JWT decode hatası: $e');
      return null;
    }
  }

  // Google ile API üzerinden giriş yap - Tek adımda işlem tamamlama
  Future<UserLoginModel?> signInWithGoogleApi() async {
    try {
      print('Google ile giriş yapılıyor...');
      print(
          'Platform: ${Platform.isAndroid ? "Android" : Platform.isIOS ? "iOS" : "Diğer"}');

      // Mevcut oturumları kapat
      await _googleSignIn.signOut();

      // Doğrudan Google hesap seçimine git
      final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();

      if (googleAccount == null) {
        throw Exception('Google hesap seçimi iptal edildi');
      }

      print('Google User Email: ${googleAccount.email}');
      print('Google User Name: ${googleAccount.displayName}');

      // Seçilen hesaptan authentication bilgilerini al
      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      // ID Token'ı kontrol et
      final String? idToken = googleAuth.idToken;
      print('Google ID Token: ${idToken != null ? "Alındı" : "Alınamadı"}');

      if (idToken == null) {
        throw Exception('Google ID Token alınamadı!');
      }

      // ID Token'ı kaydet
      try {
        if (Platform.isIOS) {
          final file = File('/Users/hasanshukurov/Desktop/google_id_token.txt');
          await file.writeAsString(idToken);
          print(
              'ID Token başarıyla MacBook masaüstüne kaydedildi: ${file.path}');

          print('----- JWT TOKEN TAM İÇERİK -----');
          print(idToken);
          print('--------------------------------');
        }
      } catch (e) {
        print('ID Token kaydedilirken hata oluştu: $e');
      }

      // Doğrudan API'ye istek gönder
      const String endpoint =
          "https://tripaz.az/api/Authentication/external-login-ios";

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'provider': 'google',
          'idToken': idToken,
        }),
      );

      print('API Yanıt Durum Kodu: ${response.statusCode}');
      print('API Yanıt İçeriği: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userModel = _saveTokens(data);
        return userModel;
      } else {
        throw Exception(
            'API hatası: ${response.statusCode}, Cevap: ${response.body}');
      }
    } catch (e) {
      print('Google API ile giriş hatası: $e');
      return null;
    }
  }

  // Get Google ID Token - Geçici olarak tutuyoruz eski kodu, ihtiyaç olursa diye
  Future<String?> getGoogleIdToken() async {
    // Doğrudan yeni metodumuza yönlendir
    try {
      final userModel = await signInWithGoogleApi();
      if (userModel != null) {
        return "success";
      }
      return null;
    } catch (e) {
      print("Google giriş hata: $e");
      rethrow;
    }
  }

  UserLoginModel _saveTokens(Map<String, dynamic> data) {
    // Token mesajını kontrol et
    if (data['message'] == 'Token valid' && data['token'] != null) {
      final tokenData = data['token'];
      return UserLoginModel(
        accessToken: tokenData['accessToken'],
        refreshToken: tokenData['refreshToken'],
      );
    } else {
      throw Exception('Backend token yanıtı geçersiz: ${data['message']}');
    }
  }

  // Apple Sign In için nonce oluşturucu metod
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  // Nonce'u SHA-256 ile hashleme metodu
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Firebase ile Apple Sign In
  Future<UserCredential> signInWithApple() async {
    try {
      // Güvenli nonce oluştur
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Apple'dan kimlik doğrulama bilgilerini al
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // OAuthCredential oluştur
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Firebase ile giriş yap
      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      print('Apple Sign In hatası: $e');
      throw Exception('Apple Sign In başarısız: $e');
    }
  }

  // Apple ID Token alma
  Future<String?> getAppleIdToken() async {
    try {
      print('Apple ile giriş yapılıyor...');
      print('Platform: ${Platform.isIOS ? "iOS" : "Diğer"}');

      // Apple'dan kimlik doğrulama bilgilerini al
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final String? idToken = appleCredential.identityToken;
      print('Apple ID Token: ${idToken != null ? "Alındı" : "Alınamadı"}');
      // Tam token değerini güvenli bir şekilde log'a ekleyin
      print('TAM_APPLE_ID_TOKEN: ${idToken ?? "Token alınamadı"}');

      if (idToken != null) {
        // Kullanıcı bilgilerini logla
        print('Apple User Email: ${appleCredential.email ?? "Belirtilmemiş"}');
        print(
            'Apple User Name: ${appleCredential.givenName ?? ""} ${appleCredential.familyName ?? ""}');

        // ID Token'ı kaydet
        try {
          if (Platform.isIOS) {
            // iOS için MacBook masaüstüne kaydet
            final file =
                File('/Users/hasanshukurov/Desktop/apple_id_token.txt');
            await file.writeAsString(idToken);
            print(
                'ID Token başarıyla MacBook masaüstüne kaydedildi: ${file.path}');
          } else {
            // Android için
            final directory = await getApplicationDocumentsDirectory();
            final file = File('${directory.path}/apple_id_token.txt');
            await file.writeAsString(idToken);
            print('ID Token başarıyla kaydedildi: ${file.path}');
          }
        } catch (e) {
          print('ID Token kaydedilirken hata oluştu: $e');
        }
      }

      return idToken;
    } catch (e) {
      print('Apple Sign In hatası: $e');

      // Hata mesajını daha anlaşılır hale getir
      if (e.toString().contains('canceled')) {
        throw Exception('Apple ile giriş iptal edildi.');
      } else if (e.toString().contains('network')) {
        throw Exception('İnternet bağlantınızı kontrol edin.');
      }

      rethrow;
    }
  }

  // Apple ile API üzerinden giriş yap
  Future<UserLoginModel?> signInWithAppleApi() async {
    try {
      final String? idToken = await getAppleIdToken();

      if (idToken == null) {
        throw Exception('Apple ID Token alınamadı!');
      }

      // API endpoint'i
      const String endpoint =
          "https://tripaz.az/api/Authentication/external-login-apple";

      // API isteği gönder
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'provider': 'apple',
          'idToken': idToken,
        }),
      );

      print('API Yanıt Durum Kodu: ${response.statusCode}');
      print('API Yanıt İçeriği: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userModel = _saveTokens(data);
        return userModel;
      } else {
        throw Exception(
            'API hatası: ${response.statusCode}, Cevap: ${response.body}');
      }
    } catch (e) {
      print('Apple API ile giriş hatası: $e');
      return null;
    }
  }
}
