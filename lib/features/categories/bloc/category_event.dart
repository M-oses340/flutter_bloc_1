abstract class CategoryEvent {}

class GetCategories extends CategoryEvent {
  final int shopId;
  GetCategories(this.shopId);
}