import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/shop_repository.dart';
import 'shop_event.dart';
import 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final ShopRepository repository;

  ShopBloc(this.repository) : super(ShopInitial()) {
    on<FetchShops>((event, emit) async {
      emit(ShopLoading());
      try {
        final shops = await repository.fetchShops();
        emit(ShopLoaded(shops));
      } catch (e) {
        emit(ShopError(e.toString()));
      }
    });
  }
}