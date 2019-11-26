import '../root_object.dart';

class Attribute extends RootObject {
  int id;
  String name;
  String value;
  dynamic metadata;
  int attributeTypeId;
  String iconName;

  Attribute(
      {this.id,
      this.attributeTypeId,
      this.name,
      this.value,
      this.metadata,
      this.iconName});

  @override
  factory Attribute.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return new Attribute(
          id: json["id"],
          name: json["name"],
          attributeTypeId: json['attribute_type_id'],
          value: json["value"]);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {'id': id};
}
