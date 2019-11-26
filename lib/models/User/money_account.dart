import '../root_object.dart';

class MoneyAccount extends RootObject {
  int id;
  String number;
  String name;
  String branch;
  int bankId;

  MoneyAccount(
      {this.id, this.number, this.name, this.bankId,this.branch});

  @override
  factory MoneyAccount.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return MoneyAccount(
          id: json["id"],
          bankId: json["bank_id"],
          number: json["account_number"],
          branch:json['bank_branch'],
          name: json["account_name"]);
    }
    return null;
  }

  @override
  String toString() {
    return "$name";
  }
}

class Bank extends RootObject {
  int id;
  String code;
  String name;
  String logo;

  Bank({this.id, this.code, this.name, this.logo});

  @override
  factory Bank.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return Bank(
          id: json["id"],
          name: json["name"],
          code: json["code"],
          logo: json["logo"]
      );
    }
    return null;
  }
}

class BankType extends RootObject {
  int id;
  String code;
  String name;

  BankType({this.id, this.code, this.name});

  @override
  factory BankType.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return BankType(
          id: json["id"],
          name: json["name"],
          code: json["code"],
      );
    }
    return null;
  }
}

