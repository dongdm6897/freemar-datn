import 'package:flutter_rentaza/models/Address/district.dart';
import 'package:flutter_rentaza/models/Address/province.dart';
import 'package:flutter_rentaza/models/Address/street.dart';
import 'package:flutter_rentaza/models/Address/ward.dart';
import 'package:flutter_rentaza/providers/api_list.dart';
import 'package:flutter_rentaza/providers/api_provider.dart';

class AddressApiProvider extends ApiProvider {
  AddressApiProvider() : super() {
    apiUrlSuffix = "/address";
  }

  Future<List<Province>> getProvince() async {
    var jsonData = await this.getData(ApiList.API_GET_PROVINCE, null);

    if (jsonData != null) {
      return List<Province>.from(
          jsonData['data'].map((e) => Province.fromJSON(e)));
    }
    return null;
  }

  Future<List<District>> getDistrict(Map params) async {
    var jsonData = await this.getData(ApiList.API_GET_DISTRICT, params);

    if (jsonData != null) {
      return List<District>.from(
          jsonData['data'].map((e) => District.fromJSON(e)));
    }
    return null;
  }

  Future<List<Street>> getStreet(Map params) async {
    var jsonData = await this.getData(ApiList.API_GET_STREET, params);

    if (jsonData != null) {
      return new List<Street>.from(
          jsonData['data'].map((e) => Street.fromJSON(e)));
    }

    return null;
  }

  Future<List<Ward>> getWard(Map params) async {
    var jsonData = await this.getData(ApiList.API_GET_WARD, params);

    if (jsonData != null) {
      return new List<Ward>.from(jsonData['data'].map((e) => Ward.fromJSON(e)));
    }

    return null;
  }
}
