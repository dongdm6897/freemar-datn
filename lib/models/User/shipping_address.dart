import 'package:flutter_rentaza/models/Address/district.dart';
import 'package:flutter_rentaza/models/Address/province.dart';
import 'package:flutter_rentaza/models/Address/street.dart';
import 'package:flutter_rentaza/models/Address/ward.dart';

import '../root_object.dart';

class ShippingAddress extends RootObject {
  int id;
  String name;
  String address;
  String phoneNumber;
  Province province;
  District district;
  Ward ward;
  Street street;

  ShippingAddress(
      {this.id,
      this.name,
      this.address,
      this.phoneNumber,
      this.province,
      this.district,
      this.street,
      this.ward});

  @override
  factory ShippingAddress.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return new ShippingAddress(
          id: json["id"],
          name: json["name"],
          address: json["address"],
          phoneNumber: json["phone_number"],
          province: Province.fromJSON(json["province"]),
          district: District.fromJSON(json["district"]),
          ward: Ward.fromJSON(json["ward"]),
          street: Street.fromJSON(json["street"]));
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'phone_number': phoneNumber,
        'province_id': province.id,
        'district_id': district.id,
        'ward_id': ward.id,
        'street_id': street?.id,
      };

  @override
  String toString() {
    return "$name, $address, ${province.name}, ${district.name},${ward.name}";
  }
}
