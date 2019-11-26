import '../root_object.dart';

class Province extends RootObject {
  int id;
  String name;
  String code;

  Province({this.id, this.name, this.code});

  @override
  factory Province.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return Province(id: json["id"], name: json["_name"], code: json["_code"]);
    }
    return null;
  }

  @override
  bool operator ==(other) =>
      identical(this, other) ||
          other is Province &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
