
class BookModel {
  String title;
  String catalog;
  String tags;
  String sub1;
  String sub2;
  String img;
  String reading;
  String online;
  String bytime;

  BookModel({
    this.title,
    this.catalog,
    this.tags,
    this.sub1,
    this.sub2,
    this.img,
    this.reading,
    this.online,
    this.bytime,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      title: json['title'] as String,
      catalog: json['title'] as String,
      tags: json['tags'] as String,
      sub1: json['sub1'] as String,
      sub2: json['sub2'] as String,
      img: json['img'] as String,
      reading: json['reading'] as String,
      online: json['online'] as String,
      bytime: json['bytime'] as String,
    );
  }
}
