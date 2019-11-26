import 'package:flutter_rentaza/models/Product/ship_provider_service.dart';

import '../root_object.dart';

class ShipProvider extends RootObject {
  int id;
  String name;
  String logo;
  String description;
  String company;
  String address;
  String email;
  String phone;
  List<ShipProviderService> shipProviderService;

  ShipProvider(
      {this.id,
      this.name,
      this.logo,
      this.company,
      this.email,
      this.address,
      this.phone,
      this.description,
      this.shipProviderService});

  @override
  factory ShipProvider.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      var data = json["ship_provider_service"]
          ?.map((e) => ShipProviderService.fromJSON(e));
      return new ShipProvider(
          id: json["id"],
          name: json["name"],
          logo: json["logo"],
          company: json["company"],
          address: json["address"],
          email: json["email"],
          phone: json["phone"],
          description: json["description"],
          shipProviderService:
          (data != null) ? List<ShipProviderService>.from(data) : null);
    }
    return null;
  }

  @override
  String toString() {
    return "$name";
  }
}
