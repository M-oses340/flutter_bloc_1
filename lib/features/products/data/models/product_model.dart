class Product {
  final int id;
  final String name;
  final String sku;
  final int categoryId;
  final String productImage;
  final double remainingQuantity;
  final double buyingPrice;
  final double sellingPrice;
  final bool isFixedPrice;
  final bool acceptFraction;
  final int shop;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.categoryId,
    required this.productImage,
    required this.remainingQuantity,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.isFixedPrice,
    required this.acceptFraction,
    required this.shop,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // Use num? and toInt() to prevent casting errors if id is missing or a double
      id: (json['id'] as num? ?? 0).toInt(),
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      categoryId: (json['category'] as num? ?? 0).toInt(),
      productImage: json['product_image'] ?? '',
      remainingQuantity: (json['remaining_quantity'] as num? ?? 0).toDouble(),
      buyingPrice: (json['buying_price'] as num? ?? 0).toDouble(),
      sellingPrice: (json['selling_price'] as num? ?? 0).toDouble(),
      isFixedPrice: json['is_fixed_price'] ?? true,
      acceptFraction: json['accept_fraction'] ?? false,
      shop: (json['shop'] as num? ?? 0).toInt(),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': categoryId,
      'product_image': productImage,
      'remaining_quantity': remainingQuantity,
      'buying_price': buyingPrice,
      'selling_price': sellingPrice,
      'is_fixed_price': isFixedPrice,
      'accept_fraction': acceptFraction,
      'shop': shop,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
