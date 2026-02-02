import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class Authenticated extends AuthState {}
class Unauthenticated extends AuthState {}

class Locked extends AuthState {
  final String email;
  const Locked(this.email);

  @override
  List<Object?> get props => [email];
}