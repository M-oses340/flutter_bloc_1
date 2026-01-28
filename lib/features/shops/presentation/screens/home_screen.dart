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
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Shops"),
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
            } else if (state is ShopLoaded) {
              if (state.shops.isEmpty) {
                return const Center(child: Text("No shops found."));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: state.shops.length,
                itemBuilder: (context, index) => ShopCard(shop: state.shops[index]),
              );
            } else if (state is ShopError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, style: const TextStyle(color: Colors.red)),
                    ElevatedButton(
                      onPressed: () => context.read<ShopBloc>().add(FetchShops()),
                      child: const Text("Retry"),
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