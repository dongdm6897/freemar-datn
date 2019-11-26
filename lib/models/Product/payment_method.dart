import 'package:flutter_rentaza/models/User/money_account.dart';

import '../root_object.dart';

class PaymentMethod extends RootObject {
  int id;
  String name;
  String logo;
  double fee;
  String description;
  BankType bankType;

  PaymentMethod({this.id, this.name, this.logo, this.fee, this.description,this.bankType});

  @override
  factory PaymentMethod.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return new PaymentMethod(
          id: json["id"],
          name: json["name"],
          logo: json["logo"],
          fee: json["fee"]?.toDouble(),
          description: json["description"]);
    }
    return null;
  }

  @override
  String toString() {
    if(bankType == null)
      return "$name";
    return "$name/${bankType.name}";
  }
}
