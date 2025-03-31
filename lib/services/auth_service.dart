import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_login_model.dart';
import 'dart:io' show Platform, File;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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

  // Doğrudan Google hesap listesi gösterip ID Token alan metod
  Future<String?> getGoogleIdToken() async {
    try {
      print('Google ile giriş yapılıyor...');
      print(
          'Platform: ${Platform.isAndroid ? "Android" : Platform.isIOS ? "iOS" : "Diğer"}');

      // Mevcut oturumları kapat
      await _googleSignIn.signOut();

      // Platform fark etmeksizin aynı akışı kullan
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

      if (idToken == null) {
        print('ID Token alınamadı! Auth nesnesi: $googleAuth');
        if (Platform.isAndroid) {
          print(
              'Android için ek hata ayıklama bilgileri: AccessToken: ${googleAuth.accessToken}');
        }
      } else {
        // Platform bazlı ID Token'ı kaydet
        try {
          if (Platform.isIOS) {
            // iOS için MacBook masaüstüne kaydet
            final file =
                File('/Users/hasanshukurov/Desktop/google_id_token.txt');
            await file.writeAsString(idToken);
            print(
                'ID Token başarıyla MacBook masaüstüne kaydedildi: ${file.path}');
          } else {
            // Android için
            final directory = await getApplicationDocumentsDirectory();
            final file = File('${directory.path}/google_id_token.txt');
            await file.writeAsString(idToken);
            print('ID Token başarıyla kaydedildi: ${file.path}');

            print('----- JWT TOKEN TAM İÇERİK -----');
            print(idToken);
            print('--------------------------------');
          }
        } catch (e) {
          print('ID Token kaydedilirken hata oluştu: $e');

          // Hata durumunda Documents klasörüne kaydetmeyi dene
          try {
            final directory = await getApplicationDocumentsDirectory();
            final file = File('${directory.path}/google_id_token.txt');
            await file.writeAsString(idToken);
            print(
                'ID Token başarıyla Documents klasörüne kaydedildi: ${file.path}');
          } catch (e) {
            print('Documents klasörüne de kaydedilemedi: $e');
          }
        }
      }

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
      } else if (Platform.isAndroid && e.toString().contains('12501')) {
        throw Exception(
            'Google Play Hizmetleri hatası. Lütfen Google hesabınızı telefonunuza ekleyin veya güncelleyin.');
      }

      rethrow;
    }
  }

  // Google ile API üzerinden giriş yap
  Future<UserLoginModel?> signInWithGoogleApi() async {
    try {
      final String? idToken = await getGoogleIdToken();

      if (idToken == null) {
        throw Exception('Google ID Token alınamadı!');
      }

      // Hem iOS hem de Android için aynı endpoint'i kullan
      const String endpoint =
          "https://tripaz.az/api/Authentication/external-login-ios";

      // API isteği gönder
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
}
