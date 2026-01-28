import '../data/models/category_model.dart';

abstract class CategoryState {}
class CategoryLoading extends CategoryState {}
class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  CategoryLoaded(this.categories);
}
class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}