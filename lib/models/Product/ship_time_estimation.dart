import '../root_object.dart';

class ShipTimeEstimation extends RootObject {
  int id;
  String name;

  ShipTimeEstimation({this.id, this.name});

  @override
  factory ShipTimeEstimation.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return new ShipTimeEstimation(
          id: json["id"], name: json["name"]);
    }
    return null;
  }
}
