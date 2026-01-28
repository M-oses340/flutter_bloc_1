import 'package:flutter/material.dart';
import '../../data/models/shop_model.dart';

class ShopDetailScreen extends StatelessWidget {
  final Shop shop;

  const ShopDetailScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(shop.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Chip
            Chip(
              label: Text(shop.isActive ? "Active" : "Inactive"),
              backgroundColor: shop.isActive ? Colors.green[100] : Colors.red[100],
            ),
            const SizedBox(height: 16),

            // Info Sections
            _infoTile(Icons.person, "Owner", shop.ownerName),
            _infoTile(Icons.location_on, "Location", shop.location ?? "No location provided"),
            _infoTile(Icons.badge, "Your Role", shop.userRole),

            const Divider(height: 40),

            const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(shop.description ?? "No description available for this shop."),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      contentPadding: EdgeInsets.zero,
    );
  }
}