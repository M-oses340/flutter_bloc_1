class Shop {
  final int id;
  final String name;
  final String ownerName;
  final String? location;
  final String? description;
  final bool isActive;
  final String userRole;

  Shop({
    required this.id,
    required this.name,
    required this.ownerName,
    this.location,
    this.description,
    required this.isActive,
    required this.userRole,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed Shop',
      ownerName: json['owner_name'] ?? 'Unknown Owner',
      location: json['location'], // Nullable
      description: json['description'], // Nullable
      isActive: json['is_active'] ?? false,
      userRole: json['user_role'] ?? 'Member',
    );
  }
}