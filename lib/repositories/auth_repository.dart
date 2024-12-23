import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<UserModel> login(String username, String password) async {
    // Servisten API çağrısı yapılır
    return await _authService.login(username, password);
  }
}
