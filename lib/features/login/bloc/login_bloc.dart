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
          // 1. Save Tokens
          await storage.saveTokens(
            access: res.data!.accessToken,
            refresh: res.data!.refreshToken,
          );

          // 2. Save Email
          await storage.saveUserEmail(event.email);

          // 3. ✅ FIX: Extract Shop ID from memberships list
          if (res.data!.user.memberships.isNotEmpty) {
            final firstShopId = res.data!.user.memberships.first.shopId;
            await storage.saveShopId(firstShopId);
          }

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
        final email = await storage.getUserEmail();
        if (email == null) {
          emit(LoginFailure("Session expired. Please log in again."));
          return;
        }

        final res = await repo.unlockWithPin(email, event.pin);

        if (res.data != null) {
          await storage.saveTokens(
            access: res.data!.accessToken,
            refresh: res.data!.refreshToken,
          );

          // 4. ✅ FIX: Also extract Shop ID during PIN unlock
          if (res.data!.user.memberships.isNotEmpty) {
            final firstShopId = res.data!.user.memberships.first.shopId;
            await storage.saveShopId(firstShopId);
          }

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