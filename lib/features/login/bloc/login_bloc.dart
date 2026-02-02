import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/storage_service.dart';
import '../../auth/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository repo;
  final StorageService storage;

  LoginBloc({required this.repo, required this.storage}) : super(LoginInitial()) {

    // 1. Full Login (Email + Password)
    on<LoginButtonPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        final res = await repo.login(event.email, event.password);
        if (res.data != null) {
          await storage.saveTokens(
            access: res.data!.accessToken,
            refresh: res.data!.refreshToken,
          );
          await storage.saveUserEmail(event.email);
          emit(LoginSuccess());
        } else {
          emit(LoginFailure("Login failed: ${res.message}"));
        }
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
    on<PinUnlocked>((event, emit) async {
      emit(LoginLoading());
      try {
        // We get the email from storage, NOT from the event
        final email = await storage.getUserEmail();

        if (email == null) {
          emit(LoginFailure("Session expired. Please log in again."));
          return;
        }

        // Call the repo using ONLY the pin from the event
        final res = await repo.unlockWithPin(email, event.pin);

        if (res.data != null) {
          await storage.saveTokens(
            access: res.data!.accessToken,
            refresh: res.data!.refreshToken,
          );
          emit(LoginSuccess());
        } else {
          emit(LoginFailure("Invalid PIN"));
        }
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}