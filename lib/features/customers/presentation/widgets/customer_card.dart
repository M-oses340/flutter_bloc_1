import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/customer_bloc.dart';
import '../../bloc/customer_event.dart';
import '../../data/models/customer_model.dart';
import '../../../../core/utils/storage_service.dart';
import '../screens/customer_details_screen.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;

  const CustomerCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.person, color: colorScheme.primary),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(customer.phoneNumber),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) => _onActionSelected(context, value),
          itemBuilder: (context) => [
            _buildMenuItem(Icons.info_outline, "View Details", "view", colorScheme.primary),
            _buildMenuItem(Icons.edit_outlined, "Edit Customer", "edit", colorScheme.primary),
            const PopupMenuDivider(),
            _buildMenuItem(Icons.delete_outline, "Delete Customer", "delete", Colors.red),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(IconData icon, String label, String value, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: value == "delete" ? Colors.red : null),
          ),
        ],
      ),
    );
  }

  void _onActionSelected(BuildContext context, String action) {
    switch (action) {
      case "view":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDetailsScreen(customer: customer),
          ),
        );
        break;
      case "edit":
      // TODO: Handle Edit
        break;
      case "delete":
        _confirmDeletion(context);
        break;
    }
  }

  void _confirmDeletion(BuildContext context) {
    // Capture dependencies before the dialog opens
    final customerBloc = context.read<CustomerBloc>();
    final storage = StorageService();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Customer"),
        content: Text("Are you sure you want to delete ${customer.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // Get shopId from storage (default to 1 if not found)
              final shopId = await storage.getShopId() ?? 1;

              customerBloc.add(DeleteCustomerEvent(
                customerId: customer.id,
                shopId: shopId,
              ));

              if (context.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${customer.name} removed."),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}