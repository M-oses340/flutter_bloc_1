import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

class LoginScreen extends StatelessWidget {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: BlocProvider(
        create: (context) => LoginBloc(
          repo: context.read(),
          storage: context.read(),
        ),
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              context.read<AuthBloc>().add(UserLoggedIn());
            }
            if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
                  TextField(controller: _pass, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
                  const SizedBox(height: 20),
                  state is LoginLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () => context.read<LoginBloc>().add(
                        LoginButtonPressed(email: _email.text, password: _pass.text)
                    ),
                    child: const Text("Login"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}