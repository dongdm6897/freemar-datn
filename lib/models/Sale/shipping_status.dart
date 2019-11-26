import 'package:flutter_rentaza/models/master_datas.dart';

import '../root_object.dart';

class ShippingStatus extends RootObject {
  int id;
  String name;

  ShippingStatus({this.id, this.name});

  @override
  factory ShippingStatus.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      int id = json["id"];
      return new ShippingStatus(
          id: id, name: ShippingStatusEnum().shippingStatusName[id - 1]);
    }
    return null;
  }
}
