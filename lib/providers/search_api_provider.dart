import 'dart:async';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Product/actions/product_search_template.dart';
import 'package:flutter_rentaza/models/Product/product.dart';

import 'api_list.dart';
import 'api_provider.dart';

class SearchApiProvider extends ApiProvider {
  SearchApiProvider() : super() {
//    mockupDataPath = 'assets/json/product.json';
//    apiBaseUrl = 'http://139.162.25.146/api/V1/search';
    apiUrlSuffix = "/search";
  }

  Future<dynamic> searchKeyword(String keyword) async {
    Map<String, String> data = Map<String, String>();
    data = {'data': keyword};
    var jsonData =
        await this.getData(ApiList.API_SEARCH_KEYWORD, data, root: '');

    if (jsonData != null) return jsonData;
    return jsonData;
  }

  Future<List<Product>> searchProduct(Map params) async {
    var jsonData =
        await this.getData(ApiList.API_SEARCH_PRODUCT, params, root: '');
    if (jsonData != null)
      return List<Product>.from(jsonData.map((e) => Product.fromJSON(e)));
    return jsonData;
  }

  Future<List<ProductSearchTemplate>> getProductSearchTmp(params) async {
    var jsonData = await this.getData(
        ApiList.API_GET_PRODUCT_SEARCH_TMP, params,
        root: 'product_search_template');

    // Extract items from json data
    return compute(
        parseProductSearchTemplates, {"json": jsonData, "i18n": S.current});
  }

  Future<bool> saveSearchHistory(Map params) async {
    var response = this.postData(ApiList.API_SAVE_SEARCH_HISTORY, params);
    response.then((onValue) {
      return onValue;
    });

    return false;
  }

  Future<bool> createSearchProduct(Map params) async {
    var response = this.postData(ApiList.API_CREATE_SEARCH_PRODUCT, params);
    response.then((onValue) {
      return onValue;
    });

    return false;
  }

  Future<bool> deleteSearchProduct(Map params) async {
    var response = this.deleteData(ApiList.API_DELETE_SEARCH_PRODUCT, params);
    response.then((res) {
      if (res) return true;
      return false;
    });
    return false;
  }

  static List<ProductSearchTemplate> parseProductSearchTemplates(
      dynamic params) {
    S.current = params["i18n"];
    final json = params["json"];
    if (json != null) {
      return new List<ProductSearchTemplate>.from(
          json.map((e) => ProductSearchTemplate.fromJSON(e)));
    }

    return null;
  }
}
