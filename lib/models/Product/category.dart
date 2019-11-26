import '../root_object.dart';
import 'attribute_type.dart';

class Category extends RootObject {
  int id;
  String name;
  String description;
  String icon;
  int parentId;

  List<Category> childrenObj;

  List<AttributeType> attributeTypes;

  String path;

  Category(
      {this.id,
      this.name,
      this.description,
      this.icon,
      this.childrenObj,
      this.attributeTypes,
      this.parentId});

  @override
  factory Category.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      var attrTypes =
          json["attribute_type"]?.map((e) => AttributeType.fromJSON(e));
      var categoryChildren = json["children"]?.map((e) => Category.fromJSON(e));

      return new Category(
          id: json["id"],
          name: json["name"],
          parentId: json['parent_id'] ?? 0,
          childrenObj: categoryChildren != null
              ? List<Category>.from(categoryChildren)
              : null,
          attributeTypes: (attrTypes != null)
              ? new List<AttributeType>.from(attrTypes)
              : null,
          description: json["description"],
          icon: json["icon"]);
    }
    return null;
  }

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  getPath(List<Category> categories) {
    String name = categories.firstWhere((c) => c.id == this.parentId).name;
    this.path = '$name > ${this.name}';
  }

  toString() => this.path ?? this.name;
}
