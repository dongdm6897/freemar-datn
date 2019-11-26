import '../root_object.dart';

class ShipProviderService extends RootObject {
  int id;
  String serviceName;
  int serviceCode;
  String description;

  ShipProviderService({
    this.id,
    this.serviceName,
    this.serviceCode,
    this.description,
  });

  @override
  factory ShipProviderService.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return ShipProviderService(
        id: json["id"],
        serviceName: json["service_name"],
        serviceCode: json["service_code"],
        description: json["description"],
      );
    }
    return null;
  }
}
