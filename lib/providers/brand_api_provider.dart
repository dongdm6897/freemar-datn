import 'dart:async';

import 'package:flutter/foundation.dart' show compute;

import '../models/Product/brand.dart';
import 'api_list.dart';
import 'api_provider.dart';

class BrandApiProvider extends ApiProvider {
  BrandApiProvider() : super() {
//    mockupDataPath = 'assets/json/brand.json';
//    apiBaseUrl = 'http://139.162.25.146/api/V1/brand';
    apiUrlSuffix = "/brand";
  }

  Future<List<Brand>> getBrands() async {
    var jsonData =
        await this.getData(ApiList.API_BRAND_GET_ALL, null, root: 'all');

    // Extract items from json data
    return compute(parseBrands, {"json": jsonData});
  }

  Future<List<Brand>> getFavoriteBrands(Map params) async {
    var jsonData = await this
        .getData(ApiList.API_FAVORITE_BRAND_GET_ALL, params, root: 'all');

    // Extract items from json data
    return compute(parseBrands, {"json": jsonData});
  }

  // Isolate implementations
  static List<Brand> parseBrands(dynamic params) {
    //TODO data->items
    final json = params["json"]["data"];

    if (json != null) {
      return new List<Brand>.from(json.map((e) => Brand.fromJSON(e)));
    }

    return null;
  }
}
