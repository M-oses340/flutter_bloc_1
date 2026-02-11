class SaleProduct {
  final int id;
  final String name;
  final String sku;
  final double price;
  final double stock;
  final String? image;

  SaleProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    this.image,
  });

  factory SaleProduct.fromJson(Map<String, dynamic> json) {
    return SaleProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      // Ensures we handle both int and double from the API
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      stock: (json['stock'] is num) ? (json['stock'] as num).toDouble() : 0.0,
      image: json['image'],
    );
  }
}