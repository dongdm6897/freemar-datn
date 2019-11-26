import 'package:flutter_rentaza/models/master_datas.dart';

import '../root_object.dart';

class OrderStatus extends RootObject {
  int id;
  String name;
  String comment;

  OrderStatus({this.id, this.name, this.comment});

  @override
  factory OrderStatus.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      int id = json["id"];
      return new OrderStatus(
        id: id,
        name: OrderStatusEnum().orderStatusName[id-1],
        comment: json["comment"],
      );
    }
    return null;
  }
}
