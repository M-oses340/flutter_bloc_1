import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginButtonPressed extends LoginEvent {
  final String email;
  final String password;

  // Use named parameters with 'const' for better performance and type safety
  const LoginButtonPressed({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}