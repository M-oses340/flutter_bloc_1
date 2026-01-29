abstract class CategoryEvent {}

class GetCategories extends CategoryEvent {
  final int shopId;
  GetCategories(this.shopId);
}
class AddCategoryRequested extends CategoryEvent { // <--- Check this name!
  final String name;
  final int shopId;
  AddCategoryRequested({required this.name, required this.shopId});
}