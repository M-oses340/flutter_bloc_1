abstract class CategoryEvent {}

// 1. Fetch all categories for a shop
class GetCategories extends CategoryEvent {
  final int shopId;
  GetCategories(this.shopId);
}

// 2. Fetch details for one specific category (The new one)
class GetCategoryDetails extends CategoryEvent {
  final int categoryId;
  GetCategoryDetails(this.categoryId);
}

// 3. Request to create a new category
class AddCategoryRequested extends CategoryEvent {
  final String name;
  final int shopId;
  AddCategoryRequested({required this.name, required this.shopId});
}

class DeleteCategoryRequested extends CategoryEvent {
  final int categoryId;
  final int shopId;
  final String categoryName; // Add this

  DeleteCategoryRequested({
    required this.categoryId,
    required this.shopId,
    required this.categoryName
  });
}