import 'package:flutter/material.dart';
import '../../../../core/services/connectivity_service.dart';

class DashboardFooter extends StatelessWidget {
  final String date;
  // We initialize the service here or pass it in via constructor
  final ConnectivityService _connectivityService = ConnectivityService();

  DashboardFooter({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            StreamBuilder<NetworkStatus>(
              stream: _connectivityService.connectivityStream,
              initialData: NetworkStatus.online,
              builder: (context, snapshot) {
                final isOnline = snapshot.data == NetworkStatus.online;
                final statusColor = isOnline ? Colors.green : Colors.red;

                return Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? "Connected" : "No Internet",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}