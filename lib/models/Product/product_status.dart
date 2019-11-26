import 'package:flutter_rentaza/models/master_datas.dart';

import '../root_object.dart';

class ProductStatus extends RootObject {
  int id;
  String name;
  String comment;

  ProductStatus({this.id, this.name, this.comment});

  @override
  factory ProductStatus.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      int id = json["id"];
      return new ProductStatus(
          id: id,
          name: ProductStatusEnum().productStatusName[id - 1],
          comment: json["comment"]);
    }
    return null;
  }
}
