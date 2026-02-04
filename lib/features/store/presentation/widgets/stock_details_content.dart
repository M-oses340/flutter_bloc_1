import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/store_bloc.dart';
import '../../data/models/store_stock.dart';
import '../screens/transfer_to_main_stock_screen.dart';

class StockDetailsContent extends StatelessWidget {
  final StoreStock stock;
  const StockDetailsContent({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏁 Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 📦 Product Header
          _buildHeader(colorScheme, textTheme, theme),

          const SizedBox(height: 24),

          // 📊 Information Sections
          _buildSectionTitle(textTheme, "Stock Information"),
          _buildInfoContainer(theme, [
            _buildDetailRow(theme, Icons.inventory_2_outlined, "Current Stock",
                "${stock.remainingQuantity} units",
                color: Colors.green),
            _buildDetailRow(theme, Icons.storefront_outlined, "Shop", stock.shopName),
          ]),

          const SizedBox(height: 20),

          _buildSectionTitle(textTheme, "Pricing"),
          _buildInfoContainer(theme, [
            _buildDetailRow(theme, Icons.payments_outlined, "Buying Price",
                "KSh ${stock.buyingPrice}"),
            _buildDetailRow(theme, Icons.attach_money, "Selling Price",
                "KSh ${stock.sellingPrice}",
                color: colorScheme.primary),
            _buildDetailRow(
                theme,
                Icons.trending_up,
                "Profit Margin",
                "${((stock.sellingPrice - stock.buyingPrice) / stock.buyingPrice * 100).toStringAsFixed(1)}%",
                color: colorScheme.secondary),
          ]),

          const SizedBox(height: 32),

          // 🔘 Action Buttons (Now passing context for navigation)
          _buildActionButtons(context, colorScheme),
        ],
      ),
    );
  }

  // --- Sub-sections ---

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.inventory_2, size: 35, color: colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stock.productName,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text("SKU: ${stock.productSku}",
                  style: textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 8),
              _buildStatusBadge(colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        stock.remainingQuantity > 0 ? "In Stock" : "Out of Stock",
        style: TextStyle(
            color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildSectionTitle(TextTheme textTheme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title,
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoContainer(ThemeData theme, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String label, String value,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.hintColor),
          const SizedBox(width: 10),
          Text(label,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
          const Spacer(),
          Text(value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color ?? theme.textTheme.bodyLarge?.color,
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text("Edit Product"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const StadiumBorder(),
              side: BorderSide(color: colorScheme.primary),
              foregroundColor: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // ✅ FIX: Capture the Bloc before the modal closes
              final storeBloc = context.read<StoreBloc>();

              Navigator.pop(context); // Close the bottom sheet

              // ✅ FIX: Provide the Bloc to the new screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: storeBloc,
                    child: TransferToMainStockScreen(stock: stock),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.sync_alt, size: 18),
            label: const Text("Transfer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const StadiumBorder(),
            ),
          ),
        ),
      ],
    );
  }
}