import 'package:flutter/material.dart';
import '../../data/models/shop_model.dart';

class ShopDashboardScreen extends StatelessWidget {
  final Shop shop;

  const ShopDashboardScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background like image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Dashboard", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Good Afternoon,", style: TextStyle(color: Colors.grey)),
            Text(shop.ownerName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Active Shop Status Card
            _buildActiveShopCard(),

            const SizedBox(height: 30),
            const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Access all features from one place", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),

            // The Grid of Actions
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.85,
              children: [
                _buildActionCard(Icons.grid_view_rounded, "Categories", Colors.teal),
                _buildActionCard(Icons.inventory_2_outlined, "Products", Colors.purple),
                _buildActionCard(Icons.monetization_on_outlined, "Expenses", Colors.redAccent),
                _buildActionCard(Icons.shopping_cart_checkout, "Make Sale", Colors.green),
                _buildActionCard(Icons.credit_card, "Credit Sale", Colors.orange),
                _buildActionCard(Icons.list_alt_rounded, "All Sales", Colors.indigo),
                _buildActionCard(Icons.people_alt_outlined, "Customers", Colors.blue),
                _buildActionCard(Icons.storefront, "Store", Colors.pinkAccent),
                _buildActionCard(Icons.bar_chart_rounded, "Reports", Colors.deepPurple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveShopCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Soft green tint
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.teal[400], borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.business, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Active Shop", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(shop.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (shop.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
              child: const Row(
                children: [
                  CircleAvatar(radius: 3, backgroundColor: Colors.white),
                  SizedBox(width: 5),
                  Text("Live", style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(width: 20, height: 2, color: color), // Small color accent line
        ],
      ),
    );
  }
}