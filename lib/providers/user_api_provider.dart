import 'dart:async';

import 'package:flutter_rentaza/models/User/shipping_address.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/providers/api_list.dart';
import 'package:simple_logger/simple_logger.dart';

import 'api_provider.dart';

class UserApiProvider extends ApiProvider {
  final SimpleLogger _logger = SimpleLogger()
    ..mode = LoggerMode.print
    ..setLevel(Level.INFO, includeCallerInfo: true);

  UserApiProvider() : super() {
//    mockupDataPath = 'assets/json/users.json';
//    apiBaseUrl = 'http://139.162.25.146/api/V1/user';
    apiUrlSuffix = "/user";
  }

  Future<List<User>> getAllSeller(Map params) async {
    var jsonData =
        await this.getData(ApiList.API_GET_ALL_SELLER, params, root: 'all');

    if (jsonData != null) {
      return new List<User>.from(jsonData['data'].map((e) => User.fromJSON(e)));
    }
    return null;
  }

  Future<List<User>> getFollowUser(Map params) async {
    var jsonData =
        await this.getData(ApiList.API_GET_FOLLOW_USER, params, root: 'all');

    if (jsonData != null) {
      return new List<User>.from(jsonData['data'].map((e) => User.fromJSON(e)));
    }
    return null;
  }

  Future<bool> addFavoriteBrand(Map params) async {
    var response =
        await this.postData(ApiList.API_FAVORITE_BRAND_CREATE, params);
    if (response != null) {
      if (response['status'] == 'success') {
        return true;
      }
    }
    return false;
  }

  Future<bool> deleteFavoriteBrand(Map params) async {
    bool response =
        await this.deleteData(ApiList.API_FAVORITE_BRAND_DELETE, params);
    if (response) {
      return true;
    }
    return false;
  }

  Future<bool> addFavoriteCategory(Map params) async {
    var response =
        await this.postData(ApiList.API_FAVORITE_CATEGORY_CREATE, params);
    if (response != null) {
      if (response['status'] == 'success') {
        return true;
      }
    }
    return false;
  }

  Future<bool> deleteFavoriteCategory(Map params) async {
    bool response =
        await this.deleteData(ApiList.API_FAVORITE_CATEGORY_DELETE, params);
    if (response) {
      return true;
    }
    return false;
  }

  Future<dynamic> updateUserStatus(Map params) async {
    var response = await this.putData(ApiList.API_EMAIL_VALIDATION, params);
    return response;
  }

  Future<bool> updateFollowStatus(Map params) async {
    _logger.info("[updateFollowStatus] params=$params");
    var result = await this.postData(ApiList.API_SET_FOLLOW_USER, params);
    _logger.info("[updateFollowStatus] response=$result");

    return result != null ? result['status'] == "success" : false;
  }

  Future<bool> updateWatchedStatus(Map params) async {
    _logger.info("[updateWatchedStatus] params=$params");
    var result = await this.postData(ApiList.API_SET_WATCHED_PRODUCT, params);
    _logger.info("[updateWatchedStatus] response=$result");

    return result != null ? result['status'] == "success" : false;
  }

  Future<int> updateFavoriteProductStatus(Map params) async {
    _logger.info("[updateFavoriteProductStatus] params=$params");
    var result = await this.postData(ApiList.API_SET_FAVORITE_PRODUCT, params);
    _logger.info("[updateFavoriteProductStatus] response=$result");
    if (result != null && result.containsKey('number_of_favorite'))
      return result['number_of_favorite'];
    return 0;
  }

  Future<ShippingAddress> updateShippingAddress(Map params) async {
    _logger.info("[updateShippingAddress] params=$params");
    var result = await this.postData(ApiList.API_SET_SHIPPING_ADDRESS, params);
    _logger.info("[updateShippingAddress] response=$result");

    //    return ShippingAddress.fromJSON(jsonDecode(result));
    if (result != null) return ShippingAddress.fromJSON(result);
    return null;
  }

  Future<bool> deleteShippingAddress(Map params) async{
    bool response =
    await this.deleteData(ApiList.API_DELETE_SHIPPING_ADDRESS, params);
    if (response) {
      return true;
    }
    return false;
  }

  Future<dynamic> updateUserInfos(Map params) async {
    _logger.info("[updateUserInfos] params=$params");
    var result = await this.postData(ApiList.API_SET_USER, params);
    _logger.info("[updateUserInfos] response=$result");

    if (result != null) {
      if (result['status'] == 'success') {
        return true;
      }
    }
    return false;
  }
}
