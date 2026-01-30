import 'package:flutter/material.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../products/presentation/screens/product_list_screen.dart';

class DashboardActionGrid extends StatelessWidget {
  final int shopId;

  const DashboardActionGrid({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    final actions = _getActions(context);

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
          child: _ActionCard(icon: item.icon, title: item.title, color: item.color),
        );
      },
    );
  }

  List<_ActionItem> _getActions(BuildContext context) {
    return [
      _ActionItem(Icons.grid_view_rounded, "Categories", Colors.teal,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoriesScreen(shopId: shopId)))),
      _ActionItem(Icons.inventory_2_rounded, "Products", Colors.teal,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListScreen(shopId: shopId)))),
      _ActionItem(Icons.monetization_on_outlined, "Expenses", Colors.redAccent),
      _ActionItem(Icons.shopping_cart_checkout, "Make Sale", Colors.green),
      _ActionItem(Icons.credit_card, "Credit Sale", Colors.orange),
      _ActionItem(Icons.list_alt_rounded, "All Sales", Colors.indigo),
      _ActionItem(Icons.people_alt_outlined, "Customers", Colors.blue),
      _ActionItem(Icons.storefront, "Store", Colors.pinkAccent),
      _ActionItem(Icons.bar_chart_rounded, "Reports", Colors.deepPurple),
    ];
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _ActionCard({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
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
}

class _ActionItem {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;
  _ActionItem(this.icon, this.title, this.color, {this.onTap});
}