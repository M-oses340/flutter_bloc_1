class Expense {
  final int? id;
  final String title;
  final String description;
  final double amount;
  final int shopId;
  final String? createdAt;
  final String? userName;

  Expense({
    this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.shopId,
    this.createdAt,
    this.userName,
  });

  // Convert JSON from API to Expense Object
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      // Safely parse string "40000.00" to double
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      shopId: json['shop'] ?? 0,
      createdAt: json['created_at'],
      userName: json['user_name'],
    );
  }

  // Convert Expense Object to JSON for POST/PATCH
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "amount": amount,
      "shop": shopId,
    };
  }
}