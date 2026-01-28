import 'package:flutter/material.dart';
import '../../data/models/shop_model.dart';
import '../screens/shop_detail_screen.dart'; // Import your detail screen

class ShopCard extends StatelessWidget {
  final Shop shop;
  const ShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ListTile(
        leading: Hero(
          tag: 'shop-icon-${shop.id}', // Hero tag for smooth transition
          child: CircleAvatar(child: Text(shop.name[0])),
        ),
        title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${shop.location ?? 'Unknown location'}\nRole: ${shop.userRole}"),
        isThreeLine: true,
        trailing: Icon(
          Icons.chevron_right,
          color: shop.isActive ? Colors.green : Colors.grey,
        ),
        onTap: () {
          // Navigate to Detail Screen and pass the shop object
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopDetailScreen(shop: shop),
            ),
          );
        },
      ),
    );
  }
}