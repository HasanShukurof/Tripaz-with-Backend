import 'package:dio/dio.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = Dio();

  Future<UserModel> login(String username, String password) async {
    final response = await _dio.post(
      'https://tripaz.azurewebsites.net/api/Authentication/login',
      data: {
        'username': username,
        'password': password,
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    } else {
      throw Exception('Login failed');
    }
  }
}
