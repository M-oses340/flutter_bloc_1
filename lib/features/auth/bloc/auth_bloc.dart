import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final StorageService storage;

  AuthBloc({required this.storage}) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      final email = await storage.getUserEmail();
      final token = await storage.getToken();
      // NEW: Check the explicit lock flag instead of the timer
      final isLocked = await storage.isLocked();

      // 1. If no email exists, user must log in from scratch
      if (email == null) {
        emit(Unauthenticated());
        return;
      }

      // 2. If the app was marked as locked (on exit), force the PIN screen
      if (isLocked) {
        emit(Locked(email));
        return;
      }

      // 3. If not locked and token exists, proceed to Home
      if (token != null) {
        emit(Authenticated());
      } else {
        // Fallback: No token means they need to re-verify PIN/Login
        emit(Locked(email));
      }
    });

    on<UserLoggedIn>((event, emit) async {
      // Clear the lock status when user successfully enters PIN/Logs in
      await storage.setLockStatus(false);
      emit(Authenticated());
    });

    on<UserLoggedOut>((event, emit) async {
      await storage.logout();
      emit(Unauthenticated());
    });
  }
}