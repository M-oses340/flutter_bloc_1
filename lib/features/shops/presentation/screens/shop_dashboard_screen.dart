import 'package:flutter/material.dart';
import '../../../../core/utils/date_fomatter.dart';
import '../../data/models/shop_model.dart';
import '../widgets/active_shop_card.dart';
import '../widgets/dashboard_action_grid.dart';
import '../widgets/dashboard_footer.dart';

class ShopDashboardScreen extends StatelessWidget {
  final Shop shop;

  const ShopDashboardScreen({super.key, required this.shop});
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning,";
    } else if (hour < 17) {
      return "Good Afternoon,";
    } else {
      return "Good Evening,";
    }
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(

      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  _getGreeting(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  shop.ownerName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                ActiveShopCard(shop: shop),
                const SizedBox(height: 30),
                Text(
                  "Quick Actions",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Access all features from one place",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,

      iconTheme: theme.appBarTheme.iconTheme,
      title: Text(
        "Home",
        style: theme.appBarTheme.titleTextStyle?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: CircleAvatar(
            radius: 14,
            // Uses primary color from theme (Teal)
            backgroundColor: theme.colorScheme.primary,
            child: Icon(
              Icons.person,
              size: 18,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}