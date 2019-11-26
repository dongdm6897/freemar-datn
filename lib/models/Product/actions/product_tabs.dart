import 'package:flutter/foundation.dart';

class ProductTabs {
  // Constant
  static const String ACTION_NEW = "new_products";
  static const String ACTION_RECENT = "recent_products";
  static const String ACTION_FREE = "free_products";
  static const String ACTION_OWNER = "owner_products";
  static const String ACTION_DRAFT = "draft_products";
  static const String ACTION_SELLING = "selling_products";
  static const String ACTION_ORDERING = "ordering_products";
  static const String ACTION_ORDERING_AUTH = "ordering_auth_products";
  static const String ACTION_SOLD = "sold_products";
  static const String ACTION_SOLD_AUTH = "sold_auth_products";
  static const String ACTION_BUYING = "buying_products";
  static const String ACTION_BOUGHT = "bought_products";
  static const String ACTION_FAVORITE = "favorite_products";
  static const String ACTION_COLLECTION = "collection_products";
  static const String ACTION_COMMENT = "comment_products";
  static const String ACTION_RELATED = "related_products";
  static const String ACTION_WATCHED = "watched_products";
  static const String ACTION_BRAND = "brand_products";
  static const String ACTION_CATEGORY = "category_products";

  // Variables
  int tabId; //Used to filter products (favoriteBrand,new,recently.....)
  String name;
  bool loadFirstPage = true;
  int pageSize;
  ProductTabs({this.tabId, @required this.name, this.pageSize})
      : assert(name != null);
}
