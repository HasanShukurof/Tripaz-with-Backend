class UserLoginModel {
  final String accessToken;
  final String refreshToken;

  UserLoginModel({required this.accessToken, required this.refreshToken});

  factory UserLoginModel.fromJson(Map<String, dynamic> json) {
    return UserLoginModel(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
