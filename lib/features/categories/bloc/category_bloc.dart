import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';
import '../data/repositories/category_repository.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  CategoryBloc(this.repository) : super(CategoryLoading()) {

    // 1. Handle Fetching Categories
    on<GetCategories>((event, emit) async {
      emit(CategoryLoading());
      try {
        final categories = await repository.fetchCategories(event.shopId);
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    // 2. Handle Adding Category
    on<AddCategoryRequested>((event, emit) async {
      // Note: We don't emit Loading here usually,
      // so the current list stays visible while saving
      try {
        // Send to server
        await repository.addCategory(event.name, event.shopId);

        // REFRESH: Use the same event name as defined above
        add(GetCategories(event.shopId));
      } catch (e) {
        // Ensure this matches your CategoryError constructor
        emit(CategoryError(e.toString()));
      }
    });
  }
}