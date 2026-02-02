import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState(); // Add const here

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess();
}

class LoginFailure extends LoginState {
  final String error;
  const LoginFailure(this.error); // Add const here

  @override
  List<Object?> get props => [error];
}

class Locked extends LoginState {
  final String email;
  const Locked(this.email); // This now works because parent is const

  @override
  List<Object?> get props => [email];
}