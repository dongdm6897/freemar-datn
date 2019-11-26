import '../root_object.dart';

class Ward extends RootObject {
  int id;
  String name;
  String prefix;
  int provinceId;
  int districtId;
  String ghnCode;

  Ward({this.id, this.name, this.prefix, this.provinceId, this.districtId, this.ghnCode});

  @override
  factory Ward.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return Ward(
          id: json["id"],
          name: json["_name"],
          prefix: json["_prefix"],
          provinceId: json['_province_id'],
          districtId: json['_district_id'],
          ghnCode: json['_ghn_code']);
    }
    return null;
  }

  @override
  bool operator ==(other) =>
      identical(this, other) ||
          other is Ward &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
