import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/utils/storage_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/login/presentation/login_screen.dart';
// Import the actual HomeScreen from the shops feature
import 'features/shops/presentation/screens/home_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Recommended when using plugins like Secure Storage
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
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(
          storage: context.read<StorageService>(),
        )..add(AppStarted()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shop App',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              // Now returning the actual Shop List screen when authenticated
              if (state is Authenticated) {
                return const HomeScreen();
              }
              // Shows Splash/Initial state while checking token
              if (state is AuthInitial) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}