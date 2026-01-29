import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';
import '../data/repositories/category_repository.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  CategoryBloc(this.repository) : super(CategoryLoading()) {

    // 1. Handle Fetching All Categories for a Shop
    on<GetCategories>((event, emit) async {
      emit(CategoryLoading());
      try {
        final categories = await repository.fetchCategories(event.shopId);
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    // 2. Handle Fetching a Specific Category by ID
    on<GetCategoryDetails>((event, emit) async {
      emit(CategoryLoading()); // Show spinner while fetching details
      try {
        final category = await repository.fetchCategoryById(event.categoryId);
        // This state needs to be defined in your category_state.dart
        emit(CategoryDetailsLoaded(category));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    // 3. Handle Adding Category
    on<AddCategoryRequested>((event, emit) async {
      try {
        await repository.addCategory(event.name, event.shopId);
        // Trigger refresh for the list
        add(GetCategories(event.shopId));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });
  }
}