import 'dart:async';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:simple_logger/simple_logger.dart';

import '../models/Product/product.dart';
import 'api_list.dart';
import 'api_provider.dart';

class ProductApiProvider extends ApiProvider {
  final SimpleLogger _logger = SimpleLogger()
    ..mode = LoggerMode.print
    ..setLevel(Level.INFO, includeCallerInfo: true);

  ProductApiProvider() : super() {
//    mockupDataPath = 'assets/json/product.json';
//    apiBaseUrl = 'http://139.162.25.146/api/V1/product';
    apiUrlSuffix = "/product";
  }

  Future<List<Product>> getAllProducts(Map params) async {
    var jsonData =
        await this.getData(ApiList.API_PRODUCT_GET_ALL, params, root: 'all');

    // Extract items from json data
    return compute(parseProducts, {"json": jsonData, "i18n": S.current});
  }

  Future<Product> getProduct(Map params, bool internalOrder) async {
    var jsonData = await this.getData(ApiList.API_GET_PRODUCT, params);

    // Extract items from json data
    return compute(parseProduct,
        {"json": jsonData, "internal_order": internalOrder, "i18n": S.current});
  }

  Future<List<Product>> getNewProducts(Map params) async {
    var jsonData =
        await this.getData(ApiList.API_PRODUCT_GET_NEW, params, root: 'new');

    // Extract items from json data
    return compute(parseProducts, {"json": jsonData, "i18n": S.current});
  }

  Future<List<Product>> getRecentlyProducts(Map params) async {
    var jsonData = await this
        .getData(ApiList.API_PRODUCT_GET_RECENTLY, params, root: 'recently');

    // Extract items from json data
    return compute(parseProducts, {"json": jsonData, "i18n": S.current});
  }

  Future<List<Product>> getFreeProducts(Map params) async {
    var jsonData =
        await this.getData(ApiList.API_PRODUCT_GET_FREE, params, root: 'free');

    // Extract items from json data
    return compute(parseProducts, {"json": jsonData, "i18n": S.current});
  }

  Future<List<Product>> getProductOwner(params) async {
    var jsonData = await this
        .getData(ApiList.API_GET_PRODUCT_OWNER, params, root: 'owner');

    // Extract items from json data
    return compute(parseProducts, {"json": jsonData, "i18n": S.current});
  }

  Future<List<Product>> getProductCategory(params) async {
    var jsonData = await this.getData(ApiList.API_GET_PRODUCT_CATEGORY, params);
    return compute(parseProducts, {"json": jsonData, "i18n": S.current});
  }

  Future<List<Product>> getProductBrand(params) async {
    var jsonData = await this.getData(ApiList.API_GET_PRODUCT_BRAND, params);
    return compute(parseProducts, {"json": jsonData, "i18n": S.current});
  }

  Future<List<Product>> getRelatedProducts(Map params) async {
    var jsonData = await this.getData(ApiList.API_GET_RELATED_PRODUCTS, params,
        root: 'related_products');

    // Extract items from json data
    return compute(parseProducts, {"json": jsonData, "i18n": S.current});
  }

  Future<List<Product>> getWatchedProducts(Map params) async {
    var jsonData = await this.getData(ApiList.API_GET_WATCHED_PRODUCTS, params,
        root: 'watched_products');

    return compute(parseProducts, {"json": jsonData, "i18n": S.current});
  }

  Future<List<Product>> getFavoriteProducts(params) async {
    var jsonData = await this.getData(ApiList.API_GET_FAVORITE_PRODUCTS, params,
        root: 'favorite_products');

    // Extract items from json data
    return compute(parseProducts, {"json": jsonData, "i18n": S.current});
  }

  Future<List<Product>> getCommentedProducts(params) async {
    var jsonData = await this.getData(
        ApiList.API_GET_COMMENTED_PRODUCTS, params,
        root: 'commented_products');

    // Extract items from json data
    return compute(parseProducts, {"json": jsonData, "i18n": S.current});
  }

  Future<List<Product>> getDraftProducts(params) async {
    var jsonData = await this.getData(ApiList.API_GET_DRAFT_PRODUCTS, params,
        root: 'draft_products');

    // Extract items from json data
    return compute(parseProducts, {"json": jsonData, "i18n": S.current});
  }

  Future<List<Product>> getSellingProducts(params) async {
    var jsonData = await this.getData(ApiList.API_GET_SELLING_PRODUCTS, params,
        root: 'selling_products');

    // Extract items from json data
    return compute(parseProducts, {"json": jsonData, "i18n": S.current});
  }

  Future<List<Product>> getOrderingProducts(params) async {
    var jsonData = await this.getData(ApiList.API_GET_ORDERING_PRODUCTS, params,
        root: 'ordering_products');

    // Extract items from json data
    return compute(parseProducts, {"json": jsonData, "i18n": S.current});
  }

  Future<List<Product>> getOrderingAuthProducts(params) async {
    var jsonData =
        await this.getData(ApiList.API_GET_ORDERING_AUTH_PRODUCTS, params);

    // Extract items from json data
    return compute(parseProducts,
        {"json": jsonData, "internal_order": true, "i18n": S.current});
  }

  Future<List<Product>> getSoldProducts(params) async {
    var jsonData = await this
        .getData(ApiList.API_GET_SOLD_PRODUCTS, params, root: 'sold_products');

    // Extract items from json data
    return compute(parseProducts, {"json": jsonData, "i18n": S.current});
  }

  Future<List<Product>> getSoldAuthProducts(params) async {
    var jsonData =
        await this.getData(ApiList.API_GET_SOLD_AUTH_PRODUCTS, params);

    // Extract items from json data
    return compute(parseProducts,
        {"json": jsonData, "internal_order": true, "i18n": S.current});
  }

  Future<List<Product>> getBuyingProducts(params) async {
    var jsonData = await this.getData(ApiList.API_GET_BUYING_PRODUCTS, params,
        root: 'buying_products');

    // Extract items from json data
    return compute(parseProducts,
        {"json": jsonData, "internal_order": true, "i18n": S.current});
  }

  Future<List<Product>> getBoughtProducts(params) async {
    var jsonData = await this.getData(ApiList.API_GET_BOUGHT_PRODUCTS, params,
        root: 'bought_products');

    // Extract items from json data
    return compute(parseProducts,
        {"json": jsonData, "internal_order": true, "i18n": S.current});
  }

  // Isolate implementations
  static List<Product> parseProducts(dynamic params) {
    S.current = params["i18n"];

    final json = params["json"]["data"];
    final setInternalOrder = params["internal_order"];

    if (json != null) {
      if (setInternalOrder == null) {
        // Extract items from json data
        return new List<Product>.from(json.map((e) => Product.fromJSON(e)));
      } else {
        return new List<Product>.from(json.map((e) {
          var p = Product.fromJSON(e);
          p.inOrderObj?.productObj = p;
          return p;
        }));
      }
    }
    return null;
  }

  static Product parseProduct(dynamic params) {
    S.current = params["i18n"];
    final json = params["json"]["data"][0];
    final setInternalOrder = params["internal_order"];
    if (json != null) {
      if (!setInternalOrder) {
        return Product.fromJSON(json);
      } else {
        var p = Product.fromJSON(json);
        p.inOrderObj?.productObj = p;
        return p;
      }
    }
    return null;
  }

  Future<Product> updateProduct(params) async {
    var result = await this.postData(ApiList.API_SET_PRODUCT, params);
    return result != null ? Product.fromJSON(result[0]) : null;
  }

  Future<bool> deleteProduct(params) async {
    bool res = await this.deleteData(ApiList.API_DELETE_PRODUCT, params);
    return res ? true : false;
  }
}
