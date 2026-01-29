import '../data/models/category_model.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

// For the List View
class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  CategoryLoaded(this.categories);
}

// For the Detail View
class CategoryDetailsLoaded extends CategoryState {
  final Category category;
  CategoryDetailsLoaded(this.category);
}

class CategoryDeleted extends CategoryState {
  final String categoryName; // This defines the getter the error is complaining about

  CategoryDeleted(this.categoryName);

  List<Object?> get props => [categoryName];
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}