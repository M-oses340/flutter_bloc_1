import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';
import '../data/repositories/category_repository.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  CategoryBloc(this.repository) : super(CategoryLoading()) {
    // Listen for GetCategories event
    on<GetCategories>((event, emit) async {
      emit(CategoryLoading());
      try {
        // Pass the shopId from the event to the repository function
        final categories = await repository.fetchCategories(event.shopId);
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });
  }
}