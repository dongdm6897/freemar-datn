import 'dart:async';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_rentaza/models/User/identify_photo.dart';

import 'api_list.dart';
import 'api_provider.dart';

class IdentityApiProvider extends ApiProvider {
  IdentityApiProvider() : super() {
//    apiBaseUrl = 'http://139.162.25.146/api/V1/identity';
    apiUrlSuffix = "/identity";
  }

  Future<bool> verifyPhoto(Map params) async {
    var jsonData = await this.postData(ApiList.API_VERIFY_PHOTO, params);

    return compute(parseData, {"json": jsonData});
  }

  Future<bool> verifyAddress(Map params) async {
    var jsonData = await this.getData(ApiList.API_VERIFY_ADDRESS, params);

    return compute(parseData, {"json": jsonData});
  }

  Future<IdentifyPhoto> getPhotoVerified(Map params) async {
    var jsonData = await this.getData(ApiList.API_GET_PHOTO_VERIFIED, params);

    return IdentifyPhoto.fromJSON(jsonData);
  }

  static bool parseData(dynamic params) {
    final json = params["json"]["status"];

    if (json != null) {
      if (json == 'success') return true;
    }
    return false;
  }
}
