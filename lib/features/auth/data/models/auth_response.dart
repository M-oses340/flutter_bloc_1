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
  final String refreshToken; // Added this just in case you need it later

  UserData({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    print("DEBUG RAW JSON: $json");
    // Attempt to find tokens in a sub-map, but fall back to the main map if missing
    final tokens = json["tokens"] as Map<String, dynamic>?;

    return UserData(
      user: User.fromJson(json["user"]),
      // If tokens?["access"] is null, it checks json["access"]
      accessToken: tokens?["access"] ?? json["access"] ?? "",
      refreshToken: tokens?["refresh"] ?? json["refresh"] ?? "",
    );
  }
}

class User {
  final int id;
  final String username;
  final String email;
  final List<ShopMembership> memberships; // Important for your Shop logic

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.memberships,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    username: json["username"] ?? "",
    email: json["email"] ?? "",
    memberships: (json["shop_memberships"] as List? ?? [])
        .map((m) => ShopMembership.fromJson(m))
        .toList(),
  );
}

class ShopMembership {
  final int id;
  final int shopId;
  final String shopName;

  ShopMembership({required this.id, required this.shopId, required this.shopName});

  factory ShopMembership.fromJson(Map<String, dynamic> json) => ShopMembership(
    id: json["id"],
    shopId: json["shop"],
    shopName: json["shop_name"] ?? "",
  );
}