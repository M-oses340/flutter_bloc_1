import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final StorageService storage;

  AuthBloc({required this.storage}) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      final token = await storage.getToken();
      emit(token != null ? Authenticated() : Unauthenticated());
    });

    on<UserLoggedIn>((event, emit) => emit(Authenticated()));

    on<UserLoggedOut>((event, emit) async {
      await storage.logout();
      emit(Unauthenticated());
    });
  }
}