import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Core & Shared
import 'core/theme/app_theme.dart';
import 'core/utils/storage_service.dart';
import 'shared/widgets/app_lifecycle_wrapper.dart';

// Auth Feature
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/repositories/auth_repository.dart';

// Login Feature
import 'features/login/bloc/login_bloc.dart';
import 'features/login/presentation/screens/login_screen.dart';
import 'features/login/presentation/screens/pin_lock_screen.dart';

// Expense & Shop Features
import 'features/expenses/data/repositories/expense_repository.dart';
import 'features/expenses/bloc/expense_bloc.dart';
import 'features/shops/presentation/screens/home_screen.dart';

void main() async {
  // Ensure Flutter engine is ready before calling native code/plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (API keys, etc.)
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
          // 1. AuthBloc handles the high-level session state
          BlocProvider(
            create: (context) => AuthBloc(
              storage: context.read<StorageService>(),
            )..add(AppStarted()),
          ),

          // 2. LoginBloc handles the login and PIN verification requests
          BlocProvider(
            create: (context) => LoginBloc(
              repo: context.read<AuthRepository>(),
              storage: context.read<StorageService>(),
            ),
          ),

          // 3. ExpenseBloc handles the data fetching for the app
          BlocProvider(
            create: (context) => ExpenseBloc(
              repository: context.read<ExpenseRepository>(),
            ),
          ),
        ],
        child: AppLifecycleWrapper(
          // This wrapper listens for app backgrounding to lock the UI
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Shop App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,

            // The Top-Level Router
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                // Logic Flow:
                // Authenticated -> Token is valid, app is unlocked.
                // Locked -> User email exists but PIN verification required.
                // AuthInitial -> First boot, reading from secure storage.
                // Default -> No user found, show login.

                if (state is Authenticated) {
                  return const HomeScreen();
                }

                if (state is Locked) {
                  return PinLockScreen(email: state.email);
                }

                if (state is AuthInitial) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                return const LoginScreen();
              },
            ),
          ),
        ),
      ),
    );
  }
}