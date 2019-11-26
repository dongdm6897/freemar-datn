import '../root_object.dart';

class Brand extends RootObject {
  int id;
  String name;
  String description;
  String image;

  Brand({this.id, this.name, this.description, this.image});

  @override
  factory Brand.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return new Brand(
          id: json["id"],
          name: json["name"],
          description: json["description"],
          image: json["image"]);
    }
    return null;
  }

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is Brand &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString(){
    return this.name;
  }
}
