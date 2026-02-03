class StoreStock {
  final int id;
  final int product;
  final String productName;
  final String productSku;
  final int shop;
  final String shopName;
  final double quantity;
  final double remainingQuantity;
  final double buyingPrice;
  final double sellingPrice;
  final DateTime? expiryDate;
  final bool transferred;
  final int? restockedBy;
  final String? restockedByName;
  final DateTime createdAt;

  StoreStock({
    required this.id,
    required this.product,
    required this.productName,
    required this.productSku,
    required this.shop,
    required this.shopName,
    required this.quantity,
    required this.remainingQuantity,
    required this.buyingPrice,
    required this.sellingPrice,
    this.expiryDate,
    required this.transferred,
    this.restockedBy,
    this.restockedByName,
    required this.createdAt,
  });

  factory StoreStock.fromJson(Map<String, dynamic> json) {
    return StoreStock(
      id: json['id'],
      product: json['product'],
      productName: json['product_name'] ?? '',
      productSku: json['product_sku'] ?? '',
      shop: json['shop'],
      shopName: json['shop_name'] ?? '',
      // Uses .toDouble() to safely handle int or double from JSON
      quantity: (json['quantity'] as num).toDouble(),
      remainingQuantity: (json['remaining_quantity'] as num).toDouble(),
      buyingPrice: (json['buying_price'] as num).toDouble(),
      sellingPrice: (json['selling_price'] as num).toDouble(),
      // Handle nullable date
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      transferred: json['transferred'] ?? false,
      restockedBy: json['restocked_by'],
      restockedByName: json['restocked_by_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'shop': shop,
      'quantity': quantity,
      'buying_price': buyingPrice,
      'selling_price': sellingPrice,
      'expiry_date': expiryDate?.toIso8601String().split('T')[0], // YYYY-MM-DD
    };
  }
}