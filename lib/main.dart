import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/storage_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/expenses/data/repositories/expense_repository.dart';
import 'features/expenses/bloc/expense_bloc.dart';

// Import Login features
import 'features/login/bloc/login_bloc.dart';
import 'features/login/presentation/screens/login_screen.dart';
import 'features/login/presentation/screens/pin_lock_screen.dart'; // New Screen
import 'features/shops/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => StorageService()),
        RepositoryProvider(create: (_) => ExpenseRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
            AuthBloc(storage: context.read<StorageService>())
              ..add(AppStarted()),
          ),
          // Register LoginBloc so PinLockScreen can use it
          BlocProvider(
            create: (context) => LoginBloc(
              repo: context.read<AuthRepository>(),
              storage: context.read<StorageService>(),
            ),
          ),
          BlocProvider(
            create: (context) => ExpenseBloc(
              repository: context.read<ExpenseRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shop App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              // 1. Fully logged in and token is fresh
              if (state is Authenticated) {
                return const HomeScreen();
              }

              // 2. App has user info but session is locked (Show PIN UI)
              if (state is Locked) {
                return PinLockScreen(email: state.email);
              }

              // 3. App is still loading storage
              if (state is AuthInitial) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // 4. Default: Show Login (Unauthenticated)
              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}