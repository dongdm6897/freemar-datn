import 'dart:async';

import 'package:flutter/foundation.dart' show compute;

import '../models/Product/category.dart';
import 'api_list.dart';
import 'api_provider.dart';

class CategoryApiProvider extends ApiProvider {
  CategoryApiProvider() : super() {
//    mockupDataPath = 'assets/json/category.json';
//    apiBaseUrl = 'http://139.162.25.146/api/V1/categories';
    apiUrlSuffix = "/categories";
  }

  Future<List<Category>> getCategories() async {
    var jsonData =
        await this.getData(ApiList.API_CATEGORY_GET_ALL, null, root: 'all');

    // Extract items from json data
    return compute(parseCategorys, {"json": jsonData});
  }

  // Isolate implementations
  static List<Category> parseCategorys(dynamic params) {
    final json = params["json"];

    if (json != null) {
      return new List<Category>.from(json.map((e) => Category.fromJSON(e)));
    }

    return null;
  }
}
