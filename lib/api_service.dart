import 'package:dio/dio.dart';

Future<bool> login(String username, String password) async {
  final Dio dio = Dio();

  try {
    final response = await dio.post(
      'https://tripaz.azurewebsites.net/api/Authentication/login',
      data: {
        'username': username,
        'password': password,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      ),
    );

    if (response.statusCode == 200) {
      // Access Token veya Refresh Token'ı alabiliriz.
      final accessToken = response.data['accessToken'];
      print('Access Token: $accessToken');
      return true; // Başarılı giriş
    } else {
      print('Hata: ${response.data}');
      return false; // Başarısız giriş
    }
  } catch (e) {
    print('Exception: $e');
    return false; // Hata durumunda
  }
}
