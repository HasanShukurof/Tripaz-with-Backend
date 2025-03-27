import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_login_model.dart';

class AuthService {
  // Sadece Google Sign-In kullan
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    serverClientId:
        '22621409630-dd475rc31b05i1pvsudq8uje8bvugdes.apps.googleusercontent.com', // Firebase web client ID
  );
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

  // Doğrudan Google hesap listesi gösterip ID Token alan metod
  Future<String?> getGoogleIdToken() async {
    try {
      print('Google ile giriş yapılıyor...');

      // Mevcut oturumları kapat (opsiyonel, Google'ın her seferinde hesap seçimi göstermesi için)
      await _googleSignIn.signOut();

      // Doğrudan Google'a giriş yap ve hesap seçim ekranını göster
      final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();

      if (googleAccount == null) {
        throw Exception('Google hesap seçimi iptal edildi');
      }

      print('Google User Email: ${googleAccount.email}');
      print('Google User Name: ${googleAccount.displayName}');

      // Seçilen hesaptan authentication bilgilerini al
      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      // ID Token'ı döndür
      final String? idToken = googleAuth.idToken;
      print('Google ID Token: ${idToken != null ? "Alındı" : "Alınamadı"}');

      return idToken;
    } catch (e) {
      print('Google Sign In hatası: $e');

      // Hata mesajını daha anlaşılır hale getir
      if (e.toString().contains('10:')) {
        throw Exception(
            'Google hizmetleriyle bağlantı kurulamadı. Lütfen daha sonra tekrar deneyin.');
      } else if (e.toString().contains('network')) {
        throw Exception('İnternet bağlantınızı kontrol edin.');
      } else if (e.toString().contains('canceled')) {
        throw Exception('Google ile giriş iptal edildi.');
      }

      rethrow;
    }
  }

  // Google ID Token ile backend'e giriş yapma metodu
  Future<UserLoginModel> signInWithGoogleApi(String idToken,
      {bool isIOS = true}) async {
    try {
      print('Google ID Token ile backend\'e giriş yapılıyor...');

      // Platform'a göre endpoint belirleme
      final endpoint = isIOS
          ? 'https://tripaz.az/api/Authentication/external-login-ios'
          : 'https://tripaz.az/api/Authentication/external-login-google';

      // API'ye istek gönderme
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
        body: jsonEncode({'idToken': idToken}),
      );

      print('Backend yanıtı: ${response.statusCode}');
      print('Yanıt içeriği: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

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
      } else {
        throw Exception(
            'Backend authentication hatası: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Google API Login hatası: $e');
      rethrow;
    }
  }
}
