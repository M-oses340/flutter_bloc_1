import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/storage_service.dart';
import '../../auth/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository repo;
  final StorageService storage;

  LoginBloc({required this.repo, required this.storage}) : super(LoginInitial()) {

    on<LoginButtonPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        final res = await repo.login(event.email, event.password);

        final token = res.data?.accessToken ?? "";

        if (token.isNotEmpty) {
          debugPrint('🚀 [LoginBloc] SUCCESS! Token found: ${token.substring(0, 5)}...');

          emit(LoginSuccess(
            passwordUsed: event.password,
            token: token,
          ));
        } else {
          debugPrint('⚠️ [LoginBloc] ERROR: Token was empty in response!');
          emit(LoginFailure("Login succeeded, but the server didn't send a token."));
        }
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });

    /// --- PIN Unlock Logic (Local Re-auth) ---
    on<PinUnlocked>((event, emit) async {
      emit(LoginLoading());
      try {
        final email = await storage.getUserEmail();

        if (email == null) {
          emit(LoginFailure("Session expired. Please log in with your email again."));
          return;
        }

        final res = await repo.unlockWithPin(email, event.pin);

        if (res.data != null) {
          // 1. Update storage with fresh tokens
          await storage.saveTokens(
            access: res.data!.accessToken,
            refresh: res.data!.refreshToken,
          );

          if (res.data!.user.memberships.isNotEmpty) {
            final firstShopId = res.data!.user.memberships.first.shopId;
            await storage.saveShopId(firstShopId);
          }

          // 2. Emit success with the PIN used and the new token
          emit(LoginSuccess(
            passwordUsed: event.pin,
            token: res.data!.accessToken,
          ));
        } else {
          emit(LoginFailure("Invalid PIN. Please try again."));
        }
      } catch (e) {
        emit(LoginFailure("Connection error: ${e.toString()}"));
      }
    });
  }
}