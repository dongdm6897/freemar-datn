import '../root_object.dart';

class District extends RootObject {
  int id;
  String name;
  String prefix;
  int provinceId;
  int ghnCode;

  District({this.id, this.name, this.prefix, this.provinceId, this.ghnCode});

  @override
  factory District.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return District(
          id: json["id"],
          name: json["_name"],
          prefix: json["_prefix"],
          provinceId: json["_province_id"],
          ghnCode: json["_ghn_code"]
      );

    }
    return null;
  }

  @override
  bool operator ==(other) =>
      identical(this, other) ||
          other is District &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}