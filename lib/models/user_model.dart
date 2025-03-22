class UserModel {
  String? profileImageUrl;
  String? userName;

  UserModel({this.profileImageUrl, this.userName});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      profileImageUrl: json['profileImageUrl'],
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileImageUrl': profileImageUrl,
      'userName': userName,
    };
  }
}
