import '../root_object.dart';

class CommerceFee extends RootObject {
  int id;
  double value;
  int categoryId;
  DateTime validFrom;
  DateTime validTo;

  CommerceFee(
      {this.id, this.value, this.categoryId, this.validFrom, this.validTo});

  @override
  factory CommerceFee.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return new CommerceFee(
          id: json["id"],
          value: json["value"],
          categoryId: json["category_id"],
          validFrom: DateTime.parse(json["valid_from"]),
          validTo: DateTime.parse(json["valid_to"]));
    }
    return null;
  }
}
