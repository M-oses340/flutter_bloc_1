import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../bloc/shop_bloc.dart';
import '../../bloc/shop_event.dart';
import '../../bloc/shop_state.dart';
import '../../data/repositories/shop_repository.dart';
import '../widgets/shop_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We grab the theme data once at the top for easy access
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Uses scaffoldBackgroundColor from your AppTheme
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
            "My Shops",
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(UserLoggedOut()),
          )
        ],
      ),
      body: BlocProvider(
        create: (context) => ShopBloc(
          ShopRepository(context.read()),
        )..add(FetchShops()),
        child: BlocBuilder<ShopBloc, ShopState>(
          builder: (context, state) {
            if (state is ShopLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ShopLoaded) {
              if (state.shops.isEmpty) {
                return Center(
                  child: Text(
                    "No shops found.",
                    // Uses the onSurface color which is white in Dark and black in Light
                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: state.shops.length,
                itemBuilder: (context, index) => ShopCard(shop: state.shops[index]),
              );
            }

            if (state is ShopError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Icon(Icons.error_outline, color: colorScheme.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                        state.message,
                        style: TextStyle(color: colorScheme.error)
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.read<ShopBloc>().add(FetchShops()),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    )
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}