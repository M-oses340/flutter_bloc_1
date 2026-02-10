// lib/features/login/bloc/login_state.dart

abstract class LoginState {
  const LoginState();
}

/// The initial state before any action is taken
class LoginInitial extends LoginState {}

/// State emitted while the API request is in progress
class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String token;
  final String passwordUsed; // ✅ Add this field

  LoginSuccess({required this.token, required this.passwordUsed});
}

/// State emitted when an error occurs
class LoginFailure extends LoginState {
  final String error;

  const LoginFailure(this.error);
}