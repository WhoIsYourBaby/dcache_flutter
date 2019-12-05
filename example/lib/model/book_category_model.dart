
class BookCategoryModel {
  String id;
  String catalog;

  BookCategoryModel({this.id, this.catalog});

  factory BookCategoryModel.fromJson(Map<String, dynamic> json) {
    return BookCategoryModel(
      id: json['id'] as String,
      catalog: json['catalog'] as String,
    );
  }
}