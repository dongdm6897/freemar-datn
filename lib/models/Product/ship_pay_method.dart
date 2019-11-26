import 'package:flutter_rentaza/models/master_datas.dart';

import '../root_object.dart';

class ShipPayMethod extends RootObject {
  int id;
  String name;
  String description;

  ShipPayMethod({this.id, this.name, this.description});

  @override
  factory ShipPayMethod.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      int id = json["id"];
      return new ShipPayMethod(
          id: json["id"],
          name: ShipPayMethodEnum().shipPayMethodName[id - 1],
          description: json["description"]);
    }
    return null;
  }
}
