import 'package:flutter/material.dart';
import '../../data/models/customer_model.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  String _formatMemberDate(DateTime? date) {
    if (date == null) return "N/A";
    try {
      final List<String> months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      // Use the DateTime properties directly
      return "${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Profile"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : "?",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
                customer.name,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
            ),
            Text(customer.phoneNumber, style: theme.textTheme.bodyMedium),

            const SizedBox(height: 24),
            const Divider(),

            // Stats / Info Section
            _buildInfoRow(Icons.badge_outlined, "Customer ID", "#${customer.id}"),

            // ✅ Dynamically pulling from customer.createdAt
            _buildInfoRow(
                Icons.calendar_today,
                "Member Since",
                _formatMemberDate(customer.createdAt)
            ),

            _buildInfoRow(Icons.shopping_bag_outlined, "Total Purchases", "0 Orders"),

            const SizedBox(height: 32),

            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Tip: You can use url_launcher package here for WhatsApp
                },
                icon: const Icon(Icons.message),
                label: const Text("Contact Customer"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}