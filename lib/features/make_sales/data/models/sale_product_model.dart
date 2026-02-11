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
      id: (json['id'] as num? ?? 0).toInt(),
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      price: (json['selling_price'] as num? ?? 0).toDouble(),
      stock: (json['remaining_quantity'] as num? ?? 0).toDouble(),
      image: json['product_image'], // Matches your Product model key
    );
  }
}