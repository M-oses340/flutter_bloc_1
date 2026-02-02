import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shop_bloc/features/login/bloc/login_bloc.dart';
import 'package:flutter_shop_bloc/features/login/bloc/login_event.dart';
import 'package:flutter_shop_bloc/features/login/bloc/login_state.dart';
import 'package:flutter_shop_bloc/features/auth/bloc/auth_bloc.dart';
import 'package:flutter_shop_bloc/features/auth/bloc/auth_event.dart';

import '../widgets/pin_keypad.dart';
import '../widgets/pin_indicator.dart';

class PinLockScreen extends StatefulWidget {
  final String email;
  const PinLockScreen({super.key, required this.email});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _pin = "";

  void _handleKeyTap(String value) {
    if (_pin.length < 4) {
      setState(() => _pin += value);
      if (_pin.length == 4) {

        context.read<LoginBloc>().add(PinUnlocked(pin: _pin));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.read<AuthBloc>().add(UserLoggedIn());
        } else if (state is LoginFailure) {
          setState(() => _pin = "");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              final isLoading = state is LoginLoading;

              return Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        "Verify PIN",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.email,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const Spacer(),

                      PinIndicator(length: _pin.length),

                      const Spacer(),

                      AbsorbPointer(
                        absorbing: isLoading,
                        child: Opacity(
                          opacity: isLoading ? 0.5 : 1.0,
                          child: PinKeypad(
                            onKeyTap: _handleKeyTap,
                            onBackspace: () {
                              if (_pin.isNotEmpty) {
                                setState(() => _pin = _pin.substring(0, _pin.length - 1));
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      TextButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => context.read<AuthBloc>().add(UserLoggedOut()),
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        label: const Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),

                  if (isLoading)
                    Container(

                      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}