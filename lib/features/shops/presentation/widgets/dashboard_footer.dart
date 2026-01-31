import 'package:flutter/material.dart';
import '../../../../core/services/connectivity_service.dart';

class DashboardFooter extends StatelessWidget {
  final String date;

  final ConnectivityService _connectivityService = ConnectivityService();

  DashboardFooter({super.key, required this.date});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;


    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurface.withValues(alpha: 0.5),
      fontSize: 12,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date,
              style: mutedStyle,
            ),
            StreamBuilder<NetworkStatus>(
              stream: _connectivityService.connectivityStream,
              initialData: NetworkStatus.online,
              builder: (context, snapshot) {
                final isOnline = snapshot.data == NetworkStatus.online;


                final statusColor = isOnline ? Colors.greenAccent[700] : colorScheme.error;

                return Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        // Adding a small glow in dark mode makes status dots pop
                        boxShadow: [
                          if (theme.brightness == Brightness.dark)
                            BoxShadow(
                              color: statusColor!.withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? "Connected" : "No Internet",
                      style: mutedStyle,
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