import 'package:flutter/material.dart';
import '../../../../core/utils/date_fomatter.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../products/presentation/screens/product_list_screen.dart';
import '../../data/models/shop_model.dart';

class ShopDashboardScreen extends StatelessWidget {
  final Shop shop;
  final ConnectivityService _connectivityService = ConnectivityService();

  ShopDashboardScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Home", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text("Good Afternoon,", style: TextStyle(color: Colors.grey)),
                Text(
                  shop.ownerName,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildActiveShopCard(),
                const SizedBox(height: 30),
                const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text("Access all features from one place", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 20),
                _buildGridActions(context),
              ]),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildFooter(DateFormatter.fullDate),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridActions(BuildContext context) {
    final actions = [
      _ActionItem(
        Icons.grid_view_rounded,
        "Categories",
        Colors.teal,
        onTap: () {
          // shop.id is already an int, so just pass it!
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoriesScreen(shopId: shop.id),
            ),
          );
        },
      ),
      _ActionItem(
        Icons.inventory_2_rounded,
        "Products",
        Colors.teal,
        onTap: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductListScreen(shopId: shop.id),
            ),
          );
        },
      ),
      _ActionItem(Icons.monetization_on_outlined, "Expenses", Colors.redAccent),
      _ActionItem(Icons.shopping_cart_checkout, "Make Sale", Colors.green),
      _ActionItem(Icons.credit_card, "Credit Sale", Colors.orange),
      _ActionItem(Icons.list_alt_rounded, "All Sales", Colors.indigo),
      _ActionItem(Icons.people_alt_outlined, "Customers", Colors.blue),
      _ActionItem(Icons.storefront, "Store", Colors.pinkAccent),
      _ActionItem(Icons.bar_chart_rounded, "Reports", Colors.deepPurple),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.85,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final item = actions[index];
        return InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: _buildActionCard(item.icon, item.title, item.color),
        );
      },
    );
  }

  Widget _buildActiveShopCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal[400],
              borderRadius: BorderRadius.circular(12),
            ),
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
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(width: 20, height: 2, color: color),
        ],
      ),
    );
  }

  Widget _buildFooter(String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        StreamBuilder<NetworkStatus>(
          stream: _connectivityService.connectivityStream,
          initialData: NetworkStatus.online,
          builder: (context, snapshot) {
            final isOnline = snapshot.data == NetworkStatus.online;
            final statusColor = isOnline ? Colors.green : Colors.red;
            return Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(isOnline ? "Connected" : "No Internet", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;
  _ActionItem(this.icon, this.title, this.color, {this.onTap});
}