import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/snackbar.dart';

import '../../auth/repositories/auth_repository.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../../core/utils/storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade500],
          ),
        ),
        child: BlocProvider(
          create: (context) => LoginBloc(
            repo: context.read<AuthRepository>(),
            storage: context.read<StorageService>(),
          ),
          // We use the Builder widget to provide a new context BELOW the provider
          child: Builder(
            builder: (context) {
              return BlocConsumer<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state is LoginSuccess) {
                    print("🟩 Login Success: Navigating...");
                    SnackBarUtils.showSuccess(context, "Welcome back!");
                    context.read<AuthBloc>().add(UserLoggedIn());
                  }
                  if (state is LoginFailure) {
                    print("🟥 Login Failure: ${state.error}");
                    SnackBarUtils.showError(context, state.error);
                  }
                },
                builder: (context, state) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(30),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_person, size: 80, color: Colors.blue),
                              const SizedBox(height: 20),
                              const Text(
                                "Omwa Shop Management",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 30),
                              _buildTextField(
                                controller: _email,
                                label: "Email",
                                icon: Icons.email_outlined,
                                enabled: state is! LoginLoading,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _pass,
                                label: "Password",
                                icon: Icons.lock_outline,
                                isPassword: true,
                                enabled: state is! LoginLoading,
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: state is LoginLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Colors.blue.shade700,
                                  ),
                                  onPressed: () {
                                    final email = _email.text.trim();
                                    final password = _pass.text;

                                    if (email.isNotEmpty && password.isNotEmpty) {
                                      // This context now correctly finds LoginBloc
                                      context.read<LoginBloc>().add(
                                        LoginButtonPressed(
                                          email: email,
                                          password: password,
                                        ),
                                      );
                                    } else {
                                      SnackBarUtils.showError(
                                          context, "Please fill all fields");
                                    }
                                  },
                                  child: const Text(
                                    "LOGIN",
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: isPassword ? _obscureText : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

