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

      final isLocked = await storage.isLocked();

      if (email == null) {
        emit(Unauthenticated());
        return;
      }

      if (isLocked) {
        emit(Locked(email));
        return;
      }

      if (token != null) {
        emit(Authenticated());
      } else {

        emit(Locked(email));
      }
    });
    on<UserLoggedIn>((event, emit) async {

      await storage.setLockStatus(false);
      emit(Authenticated());
    });

    on<UserLoggedOut>((event, emit) async {
      await storage.logout();
      emit(Unauthenticated());
    });
  }
}