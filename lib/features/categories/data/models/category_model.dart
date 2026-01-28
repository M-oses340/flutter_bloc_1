class Category {
  final int id;
  final String name;
  final int shop;
  final String shopName;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    required this.shop,
    required this.shopName,
    required this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      // Safely handle cases where ID might come as a String or int
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      shop: _toInt(json['shop']),
      shopName: json['shop_name']?.toString() ?? 'N/A',
      isActive: json['is_active'] is bool
          ? json['is_active']
          : (json['is_active'] == 1 || json['is_active'] == 'true'),
    );
  }

  // Helper method to ensure we always get an integer
  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}