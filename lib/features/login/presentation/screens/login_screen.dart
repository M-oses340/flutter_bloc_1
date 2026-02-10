import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../bloc/login_bloc.dart';
import '../../bloc/login_event.dart';
import '../../bloc/login_state.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form.dart';
import '../screens/change_pin_screen.dart';

// ✅ 1. Changed to StatefulWidget
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ✅ 2. Define the controller here in the State class
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    // ✅ 3. Always dispose controllers to prevent memory leaks
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.2)
            ]
                : [
              colorScheme.primary.withValues(alpha: 0.8),
              colorScheme.primary
            ],
          ),
        ),
        child: BlocProvider(
          create: (context) => LoginBloc(
            repo: context.read<AuthRepository>(),
            storage: StorageService(),
          ),
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                final String secureToken = state.token;

                // ✅ 4. Use the controller to check the entered PIN
                final String usedPin = _pinController.text.trim();
                const String systemPin = "3326";

                debugPrint('🚨 [LoginScreen] Checking PIN: $usedPin');

                if (usedPin == systemPin) {
                  debugPrint('🔑 [LoginScreen] Intercepting for reset flow.');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePinScreen(
                        isForcedReset: true,
                        token: secureToken,
                      ),
                    ),
                  );
                } else {
                  context.read<AuthBloc>().add(UserLoggedIn());
                }
              } else if (state is LoginFailure) {
                SnackBarUtils.showError(context, state.error);
              }
            },
            builder: (context, state) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Card(
                    elevation: isDark ? 0 : 8,
                    color: isDark ? colorScheme.surfaceContainerLow : theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: isDark
                          ? BorderSide(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.2))
                          : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const LoginHeader(),
                          const SizedBox(height: 30),
                          LoginForm(
                            // ✅ 5. Now _pinController is defined and accessible!
                            pinController: _pinController,
                            isLoading: state is LoginLoading,
                            onLogin: (email, password) {
                              if (email.isNotEmpty && password.isNotEmpty) {
                                context.read<LoginBloc>().add(
                                  LoginButtonPressed(
                                    email: email,
                                    password: password,
                                  ),
                                );
                              } else {
                                SnackBarUtils.showError(
                                    context, "Please enter both email and PIN");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}