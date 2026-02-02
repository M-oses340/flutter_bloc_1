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
        context.read<LoginBloc>().add(
          LoginButtonPressed(email: widget.email, password: _pin),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accessing your theme data
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
              backgroundColor: colorScheme.error, // Uses theme error color
            ),
          );
        }
      },
      child: Scaffold(
        // Uses scaffoldBackgroundColor from your AppTheme
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
                      const SizedBox(height: 40),
                    ],
                  ),

                  if (isLoading)
                    Container(
                      color: theme.scaffoldBackgroundColor.withOpacity(0.7),
                      child: Center(
                        child: CircularProgressIndicator(
                          // Uses primaryTeal defined in your colorSchemeSeed
                          color: colorScheme.primary,
                        ),
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