import '../root_object.dart';

class Street extends RootObject {
  int id;
  String name;
  String prefix;
  int provinceId;
  int districtId;

  Street({this.id, this.name, this.prefix, this.provinceId, this.districtId});

  @override
  factory Street.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return Street(
          id: json["id"],
          name: json["_name"],
          prefix: json["_prefix"],
          provinceId: json['_province_id'],
          districtId: json['_district_id']);
    }
    return null;
  }

  @override
  bool operator ==(other) =>
      identical(this, other) ||
          other is Street &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
