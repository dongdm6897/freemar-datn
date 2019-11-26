import '../root_object.dart';

class Rank extends RootObject {
  String brandName;
  int brandId;
  String categoryName;
  int categoryId;
  String image;

  Rank({this.brandName,this.brandId,this.categoryName,this.categoryId,this.image});

  @override
  factory Rank.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return new Rank(
          brandName: json["brand_name"],
          brandId: json["brand_id"],
          categoryName: json["category_name"],
          categoryId: json["category_id"],
          image: json["image"]);
    }
    return null;
  }
}
