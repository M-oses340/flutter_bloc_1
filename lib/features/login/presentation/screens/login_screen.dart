import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../bloc/login_bloc.dart';
import '../../bloc/login_event.dart';
import '../../bloc/login_state.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../../core/utils/storage_service.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                SnackBarUtils.showSuccess(context, "Welcome back!");
                context.read<AuthBloc>().add(UserLoggedIn());
              }
              if (state is LoginFailure) {
                SnackBarUtils.showError(context, state.error);
              }
            },
            builder: (context, state) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const LoginHeader(),
                          const SizedBox(height: 30),
                          LoginForm(
                            isLoading: state is LoginLoading,
                            onLogin: (email, password) {
                              if (email.isNotEmpty && password.isNotEmpty) {
                                context.read<LoginBloc>().add(
                                  LoginButtonPressed(email: email, password: password),
                                );
                              } else {
                                SnackBarUtils.showError(context, "Please fill all fields");
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