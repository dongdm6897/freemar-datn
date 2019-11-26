import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/models/Product/actions/search_history.dart';
import 'package:flutter_rentaza/models/Product/brand.dart';
import 'package:flutter_rentaza/models/Product/category.dart';
import 'package:flutter_rentaza/models/User/identify_photo.dart';
import 'package:flutter_rentaza/models/User/money_account.dart';

import '../Product/payment_method.dart';
import '../Product/product.dart';
import '../Product/ship_provider.dart';
import '../root_object.dart';
import 'shipping_address.dart';

class User extends RootObject {
  int id;
  String name;
  String introduction;
  double balance;
  String password;
  String email;
  String phone;
  String avatar;
  String coverImageLink;
  IdentifyPhoto identifyPhoto;
  int status;
  Map snsData;
  String snsId;
  String snsType;
  String accessToken;
  int pointHappy;
  int pointJustOk;
  int pointNotHappy;
  bool notifyProductComment;
  bool notifyOrderChat;
  int numberOfFollowerUsers;
  int numberOfFavoriteProducts;

  ShippingAddress currentShippingAddressObj;
  List<MoneyAccount> moneyAccounts;
  PaymentMethod currentPaymentMethodObj;
  ShipProvider currentShipProvider;

  List<dynamic> followerUserIds;
  List<Brand> favoriteBrandObjs;
  List<Category> favoriteCategoryObjs;
  List<ShippingAddress> shippingAddressObjs;

  // Interest products
  List<int> favoriteProductIds;
  List<Product> watchedProducts;
  List<Product> sellingProductObjs; //Using for get seller

  //Search history
  List<SearchHistory> searchHistories;

  User(
      {this.id,
      this.name,
      this.introduction,
      this.balance,
      this.password,
      this.email,
      this.phone,
      this.avatar,
      this.coverImageLink,
      this.identifyPhoto,
      this.status,
      this.snsData,
      this.snsId,
      this.snsType,
      this.accessToken,
      this.pointHappy,
      this.pointJustOk,
      this.pointNotHappy,
      this.followerUserIds,
      this.notifyProductComment,
      this.notifyOrderChat,
      this.favoriteBrandObjs,
      this.favoriteCategoryObjs,
      this.favoriteProductIds,
      this.watchedProducts,
      this.shippingAddressObjs,
      this.sellingProductObjs,
      this.numberOfFollowerUsers,
      this.numberOfFavoriteProducts,
      this.currentShippingAddressObj,
      this.currentPaymentMethodObj,
      this.currentShipProvider,
      this.moneyAccounts,
      this.searchHistories});

  @override
  factory User.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      var favoriteBrands =
          json["favorite_brands"]?.map((e) => Brand.fromJSON(e));
      var favoriteCategories =
          json["favorite_categories"]?.map((e) => Category.fromJSON(e));
      var shippingAddresses =
          json["shipping_addresses"]?.map((e) => ShippingAddress.fromJSON(e));

      // Interest products
      var watchedProducts =
          json["watched_products"]?.map((e) => Product.fromJSON(e));

      var sellingProducts =
          json["selling_products"]?.map((e) => Product.fromJSON(e));

      var moneyAccounts =
          json["money_accounts"]?.map((e) => MoneyAccount.fromJSON(e));

      var searchHistories =
          json['search_history']?.map((e) => SearchHistory.fromJSON(e));

      return new User(
          id: json["id"],
          name: json["name"],
          introduction: json["introduction"],
          balance: json["balance"]?.toDouble(),
          password: json["password"],
          email: json["email"],
          phone: json["phone"],
          avatar: json["avatar"],
          coverImageLink: json["cover_image_link"],
          identifyPhoto: IdentifyPhoto.fromJSON(json["identify_photo"]),
          status: json["status_id"],
          snsData: json["sns_data"],
          snsId: json["sns_id"],
          snsType: json["sns_type"],
          accessToken: json['access_token'],
          numberOfFollowerUsers: json["number_of_follower_users"],
          numberOfFavoriteProducts: json["number_of_favorite_products"],
          currentShippingAddressObj:
              ShippingAddress.fromJSON(json["default_shipping_address"]),
          moneyAccounts: (moneyAccounts != null)
              ? List<MoneyAccount>.from(moneyAccounts)
              : null,
          currentPaymentMethodObj:
              PaymentMethod.fromJSON(json["current_payment_method"]),
          currentShipProvider: json["default_shipping_provider"] != null
              ? AppBloc()
                  .shipProviders
                  .firstWhere((s) => s.id == json["default_shipping_provider"])
              : null,
          notifyProductComment: json["notify_product_comment"],
          notifyOrderChat: json["notify_order_chat"],
          pointHappy: json["point_happy"],
          pointJustOk: json["point_just_ok"],
          pointNotHappy: json["point_not_happy"],
          followerUserIds: json['followed_user_ids'],
          searchHistories: searchHistories != null
              ? List<SearchHistory>.from(searchHistories)
              : null,
          favoriteBrandObjs: (favoriteBrands != null)
              ? new List<Brand>.from(favoriteBrands)
              : null,
          favoriteCategoryObjs: (favoriteCategories != null)
              ? new List<Category>.from(favoriteCategories)
              : null,
          favoriteProductIds: json['favorite_product_ids'] != null
              ? List<int>.from(json['favorite_product_ids'])
              : null,
          watchedProducts: (watchedProducts != null)
              ? new List<Product>.from(watchedProducts)
              : null,
          sellingProductObjs: (sellingProducts != null)
              ? new List<Product>.from(sellingProducts)
              : null,
          shippingAddressObjs: (shippingAddresses != null)
              ? new List<ShippingAddress>.from(shippingAddresses)
              : null);
    }
    return null;
  }

  @override
  factory User.fromJSONSIMPLE(Map<String, dynamic> json) {
    if (json != null) {
      return new User(
        id: json["id"],
        name: json["name"],
        introduction: json["introduction"],
        balance: json["balance"]?.toDouble(),
        avatar: json["avatar"],
        status: json["status_id"],
      );
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'introduction': introduction,
        'phone': phone,
        'avatar': avatar,
        'cover_image_link': coverImageLink,
        'default_shipping_address': currentShippingAddressObj?.id,
        'default_shipping_provider': currentShipProvider?.id,
        'access_token': accessToken
      };

  bool checkFavorite(int id) {
    if (this.favoriteProductIds != null) {
      return this.favoriteProductIds.any((p) => p == id);
    }
    return false;
  }

  bool setFavorite(int id) {
    this.favoriteProductIds ??= [];

    if (!checkFavorite(id)) {
      this.favoriteProductIds.add(id);

      return true;
    }
    return false;
  }

  bool clearFavorite(id) {
    if (checkFavorite(id)) {
      this.favoriteProductIds.removeWhere((p) => p == id);
      return true;
    }
    return false;
  }

  bool setWatched(Product product) {
    this.watchedProducts ??= [];

    if (!this.watchedProducts.any((p) => p.id == product.id)) {
      this.watchedProducts.add(product);
      return true;
    }
    return false;
  }

  bool checkFollower(userId) {
    if (this.followerUserIds != null) {
      return this.followerUserIds.contains(userId);
    }
    return false;
  }

  bool setFollower(User user) {
    this.followerUserIds ??= [];

    if (!checkFollower(user.id)) {
      this.followerUserIds.add(user.id);
      return true;
    }
    return false;
  }

  bool clearFollower(userId) {
    if (checkFollower(userId)) {
      this.followerUserIds.removeWhere((u) => u == userId);
      return true;
    }
    return false;
  }

  void setNewShippingAddress(ShippingAddress address) {
    this.shippingAddressObjs ??= [];
    this.shippingAddressObjs.add(address);
  }
}
