import 'dart:async';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_rentaza/models/Product/product.dart';

import '../models/Product/collection.dart';
import 'api_list.dart';
import 'api_provider.dart';

class CollectionApiProvider extends ApiProvider {
  CollectionApiProvider() : super() {
//    mockupDataPath = 'assets/json/collection.json';
//    apiBaseUrl = 'http://139.162.25.146/api/V1/collection';
    apiUrlSuffix = "/collection";
  }

  Future<List<Collection>> getCollections() async {
    var jsonData =
        await this.getData(ApiList.API_COLLECTION_GET_ALL, null, root: 'all');

    // Extract items from json data
    return compute(parseCollections, {"json": jsonData});
  }

  Future<List<Product>> getProductCollection(Map params) async {
    var jsonData =
        await this.getData(ApiList.API_PRODUCT_COLLECTION_GET, params);

    if (jsonData != null) {
      return List<Product>.from(
          jsonData['data'].map((e) => Product.fromJSON(e)));
    }
    return null;
  }

  // Isolate implementations
  static List<Collection> parseCollections(dynamic params) {
    final json = params["json"]['data'];

    if (json != null) {
      return new List<Collection>.from(json.map((e) => Collection.fromJSON(e)));
    }

    return null;
  }
}
