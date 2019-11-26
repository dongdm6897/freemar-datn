import '../root_object.dart';

class Payment extends RootObject {
  int id;
  double amount;
  double fee;
  int orderId;
  int paymentMethodId;
  int paymentTypeId;

  String comment;
  String currency;

  Payment(
      {this.id,
      this.amount,
      this.comment,
      this.paymentTypeId,
      this.fee,
      this.orderId,
      this.paymentMethodId,
      this.currency,
      DateTime createdAt,
      DateTime updatedAt})
      : super(createdAt: createdAt, updatedAt: updatedAt);

  @override
  factory Payment.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return new Payment(
          id: json["id"],
          amount: json["amount"].toDouble(),
          paymentTypeId: json['payment_type_id'],
          comment: json["comment"],
          fee: json["fee"].toDouble(),
          paymentMethodId: json["payment_method_id"],
          currency: json["currency"],
          createdAt: DateTime.parse(json['created_at']),
          updatedAt: DateTime.parse(json['updated_at']));
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> params = {
      'amount': amount,
      'fee': fee ?? 0,
      'comment': comment,
      'payment_method_id': paymentMethodId,
      'payment_type_id': paymentTypeId,
      'currency': currency,
    };
    if (orderId != null) {
      params.addAll({'order_id': orderId});
    }

    return params;
  }
}
