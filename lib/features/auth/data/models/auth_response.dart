class AuthResponse {
  final bool error;
  final String message;
  final UserData? data;

  AuthResponse({required this.error, required this.message, this.data});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    error: json["error"] ?? false,
    message: json["message"] ?? "",
    data: json["data"] != null ? UserData.fromJson(json["data"]) : null,
  );
}

class UserData {
  final User user;
  final String accessToken;

  UserData({required this.user, required this.accessToken});

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    user: User.fromJson(json["user"]),
    accessToken: json["tokens"]["access"],
  );
}

class User {
  final int id;
  final String username;
  final String email;

  User({required this.id, required this.username, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    username: json["username"],
    email: json["email"],
  );
}