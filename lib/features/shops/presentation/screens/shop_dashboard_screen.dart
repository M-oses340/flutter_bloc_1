import 'package:flutter/material.dart';
import '../../../../core/utils/date_fomatter.dart';
import '../../data/models/shop_model.dart';
import '../widgets/active_shop_card.dart';
import '../widgets/dashboard_action_grid.dart';
import '../widgets/dashboard_footer.dart';

class ShopDashboardScreen extends StatelessWidget {
  final Shop shop;

  const ShopDashboardScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text("Good Afternoon,", style: TextStyle(color: Colors.grey)),
                Text(shop.ownerName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ActiveShopCard(shop: shop),
                const SizedBox(height: 30),
                const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text("Access all features from one place", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 20),
                DashboardActionGrid(shopId: shop.id),
              ]),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: DashboardFooter(date: DateFormatter.fullDate),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }
}