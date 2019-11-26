import 'package:flutter_rentaza/models/Product/attribute.dart';

import '../root_object.dart';

class AttributeType extends RootObject {
  int id;
  String title;
  String dataType;
  String iconName;
  String group;
  List<Attribute> attributes;

  AttributeType(
      {this.id,
      this.title,
      this.dataType,
      this.iconName,
      this.group,
      this.attributes});

  @override
  factory AttributeType.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return new AttributeType(
          id: json["id"],
          title: json["title"],
          dataType: json["data_type"],
          iconName: json["icon_name"],
          group: json["group"],
          attributes: List<Attribute>.from(
              json["attributes"]?.map((e) => Attribute.fromJSON(e))));
    }
    return null;
  }
}
