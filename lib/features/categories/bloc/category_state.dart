import '../data/models/category_model.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}
class CategoryLoading extends CategoryState {}

// For the List View
class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  CategoryLoaded(this.categories);
}

// For the Detail View (The new one)
class CategoryDetailsLoaded extends CategoryState {
  final Category category;
  CategoryDetailsLoaded(this.category);
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}