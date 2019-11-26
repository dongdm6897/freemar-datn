import '../root_object.dart';

class Collection extends RootObject {
  int id;
  String name;
  String description;
  String image;
  String searchKeywords;

  Collection(
      {this.id, this.name, this.description, this.image, this.searchKeywords});

  @override
  factory Collection.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return new Collection(
          id: json["id"],
          name: json["name"],
          description: json["description"],
          image: json["image"],
          searchKeywords: json["search_keywords"]);
    }
    return null;
  }
}
