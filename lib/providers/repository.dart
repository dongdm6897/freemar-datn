import 'dart:async';
import 'dart:io';

import 'package:flutter_rentaza/models/Address/district.dart';
import 'package:flutter_rentaza/models/Address/province.dart';
import 'package:flutter_rentaza/models/Address/street.dart';
import 'package:flutter_rentaza/models/Address/ward.dart';
import 'package:flutter_rentaza/models/Product/actions/product_search_template.dart';
import 'package:flutter_rentaza/models/Product/message.dart';
import 'package:flutter_rentaza/models/Sale/order.dart';
import 'package:flutter_rentaza/models/Sale/payment.dart';
import 'package:flutter_rentaza/models/Sale/revenue.dart';
import 'package:flutter_rentaza/models/User/identify_photo.dart';
import 'package:flutter_rentaza/models/User/shipping_address.dart';
import 'package:flutter_rentaza/providers/address_api_provider.dart';
import 'package:flutter_rentaza/providers/login_api_provider.dart';
import 'package:flutter_rentaza/providers/message_api_provider.dart';
import 'package:flutter_rentaza/providers/notification_api_provider.dart';
import 'package:flutter_rentaza/providers/payment_api_provider.dart';
import 'package:flutter_rentaza/providers/search_api_provider.dart';
import 'package:flutter_rentaza/providers/user_api_provider.dart';

import '../models/Product/brand.dart';
import '../models/Product/category.dart';
import '../models/Product/collection.dart';
import '../models/Product/product.dart';
import '../models/Product/rank.dart';
import '../models/User/user.dart';
import 'api_provider.dart';
import 'app_api_provider.dart';
import 'brand_api_provider.dart';
import 'category_api_provider.dart';
import 'collection_api_provider.dart';
import 'identity_api_provider.dart';
import 'order_api_provider.dart';
import 'products_api_provider.dart';
import 'rank_api_provider.dart';

class Repository {
  // Singleton object
  static final Repository _singleton = Repository._internal();

  factory Repository() => _singleton;

  Repository._internal();

  // Cache data
  Map<String, Object> _cacheData = new Map<String, Object>();

  final apiProvider = new ApiProvider();
  final productProvider = new ProductApiProvider();
  final searchProvider = new SearchApiProvider();
  final brandProvider = new BrandApiProvider();
  final categoryProvider = new CategoryApiProvider();
  final rankProvider = new RankApiProvider();
  final collectionProvider = new CollectionApiProvider();
  final orderProvider = new OrderApiProvider();
  final loginProvider = new LoginApiProvider();
  final appProvider = new AppApiProvider();
  final notificationProvider = new NotificationApiProvider();
  final userProvider = new UserApiProvider();
  final messageProvider = new MessageApiProvider();
  final addressProvider = new AddressApiProvider();
  final identityProvider = new IdentityApiProvider();
  final paymentProvider = new PaymentApiProvider();

  // Api provider
  Future<List<String>> uploadFiles(List<File> files, String token) =>
      apiProvider.uploadFiles(files, token);

  Future<String> uploadFile(File file, String token) =>
      apiProvider.uploadFile(file, token);

  //Product
  Future<List<Product>> getAllProducts(Map params) =>
      productProvider.getAllProducts(params);

  Future<Product> getProduct(Map params, bool internalOrder) =>
      productProvider.getProduct(params, internalOrder);

  Future<List<Product>> getNewProducts(Map params) =>
      productProvider.getNewProducts(params);

  Future<List<Product>> getRecentlyProducts(Map params) =>
      productProvider.getRecentlyProducts(params);

  Future<List<Product>> getFreeProducts(Map params) =>
      productProvider.getFreeProducts(params);

  Future<List<Product>> getProductOwner(Map params) =>
      productProvider.getProductOwner(params);

  Future<List<Product>> getProductCategory(Map params) =>
      productProvider.getProductCategory(params);

  Future<List<Product>> getProductBrand(Map params) =>
      productProvider.getProductBrand(params);

  Future<List<Product>> getRelatedProducts(Map params) =>
      productProvider.getRelatedProducts(params);

  Future<List<Product>> getWatchedProducts(Map params) =>
      productProvider.getWatchedProducts(params);

  Future<List<Product>> getFavoriteProducts(Map params) =>
      productProvider.getFavoriteProducts(params);

  Future<int> setFavoriteProduct(Map params) =>
      userProvider.updateFavoriteProductStatus(params);

  Future<bool> setFollowerUser(Map params) =>
      userProvider.updateFollowStatus(params);

  Future<bool> setWatchedProduct(Map params) =>
      userProvider.updateWatchedStatus(params);

  Future<List<Product>> getCommentedProducts(Map params) =>
      productProvider.getCommentedProducts(params);

  Future<List<Product>> getDraftProducts(Map params) =>
      productProvider.getDraftProducts(params);

  Future<List<Product>> getSellingProducts(Map params) =>
      productProvider.getSellingProducts(params);

  Future<List<Product>> getOrderingProducts(Map params) =>
      productProvider.getOrderingProducts(params);

  Future<List<Product>> getOrderingAuthProducts(Map params) =>
      productProvider.getOrderingAuthProducts(params);

  Future<List<Product>> getSoldProducts(Map params) =>
      productProvider.getSoldProducts(params);

  Future<List<Product>> getSoldAuthProducts(Map params) =>
      productProvider.getSoldAuthProducts(params);

  Future<List<Product>> getBuyingProducts(Map params) =>
      productProvider.getBuyingProducts(params);

  Future<List<Product>> getBoughtProducts(Map params) =>
      productProvider.getBoughtProducts(params);

  Future<Product> updateProduct(Map params) =>
      productProvider.updateProduct(params);

  Future<bool> deleteProduct(Map params) =>
      productProvider.deleteProduct(params);

  // Message
  Future<Message> updateMessage(Map params) =>
      messageProvider.updateMessage(params);

  Future<List> getProductCommentMessage(Map params) =>
      messageProvider.getProductCommentMessage(params);

  Future<List> getOrderChatMessage(Map params) =>
      messageProvider.getOrderChatMessage(params);

  // Order
  Future<int> updateOrder(Order order, String accessToken) =>
      orderProvider.updateOrder(order, accessToken);

  Future<bool> updateOrderStatus(Map params) =>
      orderProvider.updateOrderStatus(params);

  Future<int> updateOrderAssessment(params) =>
      orderProvider.updateOrderAssessment(params);

  //Search
  Future<dynamic> searchKeyword(String keyword) =>
      searchProvider.searchKeyword(keyword);

  Future<List<Product>> searchProduct(Map params) =>
      searchProvider.searchProduct(params);

  Future<List<ProductSearchTemplate>> getProductSearchTmp(Map params) =>
      searchProvider.getProductSearchTmp(params);

  Future<bool> saveSearchHistory(Map params) =>
      searchProvider.saveSearchHistory(params);

  Future<bool> createSearchProduct(Map params) =>
      searchProvider.createSearchProduct(params);

  Future<bool> deleteSearchProduct(Map params) =>
      searchProvider.deleteSearchProduct(params);

  // Payment
  Future<bool> createPayment(Map params) =>
      paymentProvider.createPayment(params);

  Future<List<RevenueChart>> getRevenueChart(Map params) =>
      paymentProvider.getRevenueChart(params);

  Future<Revenue> getRevenue(Map params) => paymentProvider.getRevenue(params);

  Future<List<Payment>> getPayment(Map params) =>
      paymentProvider.getPayment(params);

  Future<int> requestWithdrawal(Map params) =>
      paymentProvider.requestWithdrawal(params);

  //Brand
//  Future<List<Brand>> getAllBrands() => brandProvider.getBrands();
  Future<List<Brand>> getAllBrands(
      {reload = false, cacheCommand = true, cacheObject = false}) async {
    var key = "getAllBrands";
    if (!reload && _cacheData.containsKey(key)) {
      return _cacheData[key];
    } else {
      var retVals = brandProvider.getBrands();
      retVals.then((values) {
        if (cacheCommand) _cacheData[key] = values;
        if (cacheObject) {
          for (Brand i in values) {
            var k = i.runtimeType.toString() + "-" + i.id.toString();
            _cacheData[k] = i;
          }
        }
      });
      return retVals;
    }
  }

  Future<List<Brand>> getFavoriteBrands(Map params) =>
      brandProvider.getFavoriteBrands(params);

  Future<bool> addFavoriteBrand(Map params) =>
      userProvider.addFavoriteBrand(params);

  Future<bool> deleteFavoriteBrand(Map params) =>
      userProvider.deleteFavoriteBrand(params);

  //Ranking
//  Future<List<Rank>> getAllRanks() => rankProvider.getRanks();
  Future<List<Rank>> getAllRanks(
      {reload = false, cacheCommand = true, cacheObject = false}) async {
    var key = "getAllRanks";
    if (!reload && _cacheData.containsKey(key)) {
      return _cacheData[key];
    } else {
      var retVals = rankProvider.getRanks();
      retVals.then((values) {
        if (cacheCommand) _cacheData[key] = values;
        if (cacheObject) {
          for (Rank i in values) {
            var k = i.brandId.toString() + "-" + i.categoryId.toString();
            _cacheData[k] = i;
          }
        }
      });
      return retVals;
    }
  }

  //Categories
//  Future<List<Category>> getAllCategories() => categoryProvider.getCategories();
  Future<List<Category>> getAllCategories(
      {reload = false, cacheCommand = true, cacheObject = false}) async {
    var key = "getAllCategories";
    if (!reload && _cacheData.containsKey(key)) {
      return _cacheData[key];
    } else {
      var retVals = categoryProvider.getCategories();
      retVals.then((values) {
        if (cacheCommand) _cacheData[key] = values;
        if (cacheObject) {
          for (Category i in values) {
            var k = i.runtimeType.toString() + "-" + i.id.toString();
            _cacheData[k] = i;
          }
        }
      });
      return retVals;
    }
  }

  Future<bool> addFavoriteCategory(Map params) =>
      userProvider.addFavoriteCategory(params);

  Future<bool> deleteFavoriteCategory(Map params) =>
      userProvider.deleteFavoriteCategory(params);

  //Topic
//  Future<List<Collection>> getAllCollections() => collectionProvider.getCollections();
  Future<List<Collection>> getAllCollections(
      {reload = false, cacheCommand = true, cacheObject = false}) async {
    var key = "getAllCollections";
    if (!reload && _cacheData.containsKey(key)) {
      return _cacheData[key];
    } else {
      var retVals = collectionProvider.getCollections();
      retVals.then((values) {
        if (cacheCommand) _cacheData[key] = values;
        if (cacheObject) {
          for (Collection i in values) {
            var k = i.runtimeType.toString() + "-" + i.id.toString();
            _cacheData[k] = i;
          }
        }
      });
      return retVals;
    }
  }

  Future<List<Product>> getProductCollection(Map params) =>
      collectionProvider.getProductCollection(params);

  Future<dynamic> getMasterDatas({reload = false, cacheCommand = true}) async {
    var key = "getMasterDatas";
    if (!reload && _cacheData.containsKey(key)) {
      return _cacheData[key];
    } else {
      var retVals = appProvider.getMasterDatas();
      retVals.then((values) {
        if (cacheCommand) _cacheData[key] = values;
      });
      return retVals;
    }
  }

  //Login
  Future saveSharePref(bool isLoggedIn, int id, String accessToken) =>
      loginProvider.saveSharePref(isLoggedIn, id, accessToken);

  Future deleteSharePref() => loginProvider.deleteSharePref();

  Future saveLocalData(bool isLoggedIn, String name, String email, String id,
          String avatar) =>
      loginProvider.saveLocalData(isLoggedIn, name, email, id, avatar);

  Future deleteLocalData() => loginProvider.deleteLocalData();

  Future getLogged() => loginProvider.getLogged();

  Future getProfile(Map data) => loginProvider.getProfile(data);

  Future login(Map<String, String> params) => loginProvider.login(params);

  Future loginSocial(Map profile) => loginProvider.loginSocial(profile);

  Future signUp(Map params) => loginProvider.signUp(params);

  Future<dynamic> updateUserInfos(Map params) =>
      userProvider.updateUserInfos(params);

  //Notification
  Future<bool> sendNotification(Map params) =>
      notificationProvider.sendNotification(params);

  //User
  Future updateUserStatus(Map params) => userProvider.updateUserStatus(params);

  Future<ShippingAddress> updateShippingAddress(Map params) =>
      userProvider.updateShippingAddress(params);

  Future<bool> deleteShippingAddress(Map params) =>
      userProvider.deleteShippingAddress(params);

  Future<List<User>> getAllSeller(Map params) =>
      userProvider.getAllSeller(params);

  Future<List<User>> getFollowUser(Map params) =>
      userProvider.getFollowUser(params);

  //Address
  Future<List<Province>> getProvince() => addressProvider.getProvince();

  Future<List<District>> getDistrict(Map params) =>
      addressProvider.getDistrict(params);

  Future<List<Ward>> getWard(Map params) => addressProvider.getWard(params);

  Future<List<Street>> getStreet(Map params) =>
      addressProvider.getStreet(params);

  //Identity
  Future<bool> verifyPhoto(Map params) => identityProvider.verifyPhoto(params);

  Future<IdentifyPhoto> getPhotoVerified(Map params) =>
      identityProvider.getPhotoVerified(params);

  Future<bool> verifyAddress(Map params) =>
      identityProvider.verifyAddress(params);
}
