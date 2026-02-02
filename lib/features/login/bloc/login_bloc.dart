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

        if (res.data != null) {

          final access = res.data!.accessToken;
          final refresh = res.data!.refreshToken;


          await storage.saveTokens(
            access: access,
            refresh: refresh,
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
  }
}