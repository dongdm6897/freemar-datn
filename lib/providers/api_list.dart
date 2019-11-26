///
/// List of Apis & how to use them
///
class ApiList {
  ///
  /// REQUEST_PARAMS
  ///   - currentPage
  ///   - pageSize
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  /// COMMENTS (done)
  ///
  static const String API_PRODUCT_GET_ALL = "get_all";

  ///
  /// REQUEST_PARAMS
  ///   - param1:
  ///   - param2:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  /// COMMENTS (done)
  ///
  static const String API_PRODUCT_GET_NEW = "get_new";

  ///
  /// REQUEST_PARAMS
  ///   - param1:
  ///   - param2:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  static const String API_PRODUCT_GET_FEATURED = "get_featured";

  ///
  /// REQUEST_PARAMS
  ///   - param1:
  ///   - param2:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  /// COMMENTS (done)
  ///
  static const String API_PRODUCT_GET_RECENTLY = "get_recently";

  ///
  /// REQUEST_PARAMS
  ///   - param1:
  ///   - param2:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  /// COMMENTS (done)
  /// TODO: @Dat cai API nay giup anh nhe
  static const String API_PRODUCT_GET_FREE = "get_free";

  ///
  /// REQUEST_PARAMS
  ///   - param1:
  ///   - param2:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  /// COMMENTS (done)
  ///
  static const String API_BRAND_GET_ALL = "get_all";

  ///
  /// REQUEST_PARAMS
  ///   - param1:
  ///   - param2:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  static const String API_BRAND_GET_FEATURED = "get_featured";

  ///
  /// REQUEST_PARAMS
  ///   - param1:
  ///   - param2:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  /// COMMENTS (error)
  ///
  ///
  static const String API_CATEGORY_GET_ALL = "get_all";

  ///
  /// REQUEST_PARAMS
  ///   - param1:
  ///   - param2:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  ///
  static const String API_CATEGORY_GET_FEATURED = "get_featured";

  ///
  /// REQUEST_PARAMS
  ///   - param1:
  ///   - param2:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  /// COMMENTS (done)
  ///
  static const String API_COLLECTION_GET_ALL = "get_all";

  ///
  /// REQUEST_PARAMS
  ///   - param1:
  ///   - param2:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  /// COMMENTS (done)
  ///
  static const String API_PRODUCT_COLLECTION_GET = "get_product_collection";

  ///
  /// REQUEST_PARAMS
  ///   - param1:
  ///   - param2:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  ///
  static const String API_COLLECTION_GET_FEATURED = "get_featured";

  ///
  /// REQUEST_PARAMS
  ///   - param1:
  ///   - param2:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  ///
  static const String API_RANK_GET_ALL = "get_all";

  ///
  /// REQUEST_PARAMS
  ///   - param1:
  ///   - param2:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  ///
  static const String API_RANK_GET_FEATURED = "get_featured";

  ///
  /// REQUEST_PARAMS
  ///   - user_id :
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  /// COMMENTS (done)
  ///
  static const String API_FAVORITE_BRAND_GET_ALL = "get_favorite";

  ///
  /// Body
  ///   - user_id :
  ///   - brand_id :
  /// RESPONSE
  ///  status
  ///
  /// COMMENTS(done)
  ///
  static const String API_FAVORITE_BRAND_CREATE = "create_favorite_brand";
  static const String API_FAVORITE_BRAND_DELETE = "delete_favorite_brand";

  ///
  /// Body
  ///   - user_id :
  ///   - category_id :
  /// RESPONSE
  ///  status
  ///
  /// COMMENTS (done)
  ///
  static const String API_FAVORITE_CATEGORY_CREATE = "create_favorite_category";
  static const String API_FAVORITE_CATEGORY_DELETE = "delete_favorite_category";

  ///
  /// REQUEST_PARAMS
  ///   - keyword:
  /// RESPONSE
  ///  List of data (unique,search in the table(product,brand,list,....)) (Json data )
  ///
  static const String API_SEARCH_KEYWORD = "search_everything";

  ///
  /// REQUEST_PARAMS
  ///   - name:
  ///   - priceFrom:
  ///   - priceTo:
  ///   - shippingFeeIncluded:
  ///   - brand_id:
  ///   - category_id:
  ///   - attribute_size_id:
  ///   - attribute_color_id:
  ///   - target_gender_id:
  ///   - target_age_id:
  ///   - product_status_id:
  ///   - order_status_id:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  static const String API_SEARCH_PRODUCT = "search_product";

  ///
  /// Body
  ///   - name:
  ///   - keyword:
  ///   - priceFrom:
  ///   - priceTo:
  ///   - shippingFeeIncluded:
  ///   - brand_id:
  ///   - category_id:
  ///   - attribute_size_id:
  ///   - attribute_color_id:
  ///   - target_gender_id:
  ///   - target_age_id:
  ///   - product_status_id:
  ///   - order_status_id:
  /// RESPONSE
  ///  status
  ///
  static const String API_CREATE_SEARCH_PRODUCT = "create_search_product";

  ///
  /// Body
  ///   - product_search_template_id:
  /// RESPONSE
  ///  status
  ///
  static const String API_DELETE_SEARCH_PRODUCT = "delete_search_product";

  ///
  /// Body
  ///   - product_search_template_id:
  /// RESPONSE
  ///  status
  ///
  static const String API_GET_PRODUCT_SEARCH_TMP = "get_product_search_tmp";

  /// REQUEST_PARAMS
  ///   - param1:
  ///   - param2:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  static const String API_GET_MASTER_DATA = "get_master_data";

  /// REQUEST_PARAMS
  ///   - username:
  ///   - password:
  /// RESPONSE
  ///  objects (User - Json data)
  ///
  /// COMMENTS (done)
  ///
  static const String API_LOGIN = "login";

  /// REQUEST_PARAMS
  ///   - profile_data
  /// RESPONSE
  ///  objects (User - Json data)
  ///
  /// COMMENTS
  ///   - added: 2019/4/10 by Dat
  ///   - server implementation: done
  static const String API_LOGIN_SOCIAL = "login_social";

  /// REQUEST_PARAMS
  ///   - username
  ///   - email
  ///   - password
  ///   - password_confirmation
  /// RESPONSE
  ///   - message
  ///   - link confirm
  ///
  /// COMMENTS (done)
  ///
  static const String API_SIGN_UP = "signup";

  /// REQUEST_PARAMS
  ///   - user_id:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  /// COMMENTS (done)
  ///

  static const String API_GET_PRODUCT_OWNER = "get_by_owner";

  /// REQUEST_PARAMS
  ///   - user_id:
  /// RESPONSE
  ///  List of draft products, which is in-editing (private mode) (Json data)
  ///
  static const String API_GET_DRAFT_PRODUCTS = "get_draft";

  /// REQUEST_PARAMS
  ///   - user_id:
  /// RESPONSE
  ///  List of selling products (Json data)
  ///
  /// COMMENTS (done)
  ///
  static const String API_GET_SELLING_PRODUCTS = "get_selling";

  /// REQUEST_PARAMS
  ///   - user_id:
  /// RESPONSE
  ///  List of ordering products (Json data)
  ///
  /// COMMENTS (done)
  ///
  static const String API_GET_ORDERING_PRODUCTS = "get_ordering";

  static const String API_GET_ORDERING_AUTH_PRODUCTS = "get_ordering_auth";

  /// REQUEST_PARAMS
  ///   - user_id:
  /// RESPONSE
  ///  List of sold products (Json data)
  ///
  /// COMMENTS (done)
  ///
  static const String API_GET_SOLD_PRODUCTS = "get_sold_out";

  static const String API_GET_SOLD_AUTH_PRODUCTS = "get_sold_out_auth";

  /// REQUEST_PARAMS
  ///   - user_id:
  /// RESPONSE
  ///  List of buying products (Json data)
  ///
  /// COMMENTS (done)
  ///
  static const String API_GET_BUYING_PRODUCTS = "get_buying";

  /// REQUEST_PARAMS
  ///   - user_id:
  /// RESPONSE
  ///  List of bought products (Json data)
  ///
  /// COMMENTS (done)
  ///
  static const String API_GET_BOUGHT_PRODUCTS = "get_bought";

  /// REQUEST_PARAMS
  ///   - user_id:
  /// RESPONSE
  ///  objects (User - Json data)
  ///
  /// COMMENTS (done)
  /// TODO edit response
  ///
  static const String API_GET_PROFILE = "profile";

  /// REQUEST_PARAMS
  ///   - brand_id:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  static const String API_GET_PRODUCT_BRAND = "get_product_brand";

  /// REQUEST_PARAMS
  ///   - product_id:
  /// RESPONSE
  ///  List of objects (Json data)
  ///
  static const String API_GET_RELATED_PRODUCTS = "get_related";

  /// REQUEST_PARAMS
  ///   - user_id:
  /// RESPONSE
  ///  List of watched products (Json data)
  ///
  static const String API_GET_WATCHED_PRODUCTS = "get_watched";

  /// REQUEST_PARAMS
  ///   - user_id:
  /// RESPONSE
  ///  List of favorite products (Json data)
  ///
  /// COMMENTS (done)
  ///
  static const String API_GET_FAVORITE_PRODUCTS = "get_favorite";

  /// REQUEST_PARAMS
  ///   - user_id:
  /// RESPONSE
  ///  List of commented products (Json data)
  ///
  /// COMMENTS (done)
  ///
  static const String API_GET_COMMENTED_PRODUCTS = "get_commented";

  /// REQUEST_PARAMS
  ///   - user_id:
  ///   - email:
  /// RESPONSE
  ///  code
  ///
  static const String API_EMAIL_VALIDATION = "email_validation";

  /// REQUEST_PARAMS
  ///   - user_id:
  ///   - email:
  /// RESPONSE
  ///  code
  ///
  static const String API_UPDATE_USER_STATUS = "update_user_status";

  /// REQUEST_PARAMS
  ///   - name: table name inside DB
  ///   - fields: list of field used as search key (example id:1, name:*abc¥d{1-3} )
  ///   - mode: deep mode (get all data of entity), or preview mode (overview data with relation used for displaying on screen)
  /// RESPONSE
  ///  List of objects (Json)
  ///
  static const String API_GET_OBJECTS = "get_objects";

  /// REQUEST_PARAMS
  ///   - name: table name inside DB
  ///   - objects: list of objects (json formats), need to update/insert into database
  /// RESPONSE
  ///  List of result (true/false for each object operation)
  ///
  static const String API_SET_OBJECTS = "set_objects";

  /// REQUEST_PARAMS
  ///   - name: table name inside DB
  ///   - fields: list of field used as search key (example id:1, name:*abc¥d{1-3} )
  /// RESPONSE
  ///  List of result (true/false for each object operation)
  ///
  static const String API_DELETE_OBJECTS = "delete_objects";

  ///
  /// REQUEST_PARAMS
  ///   - params: json data contains product informations
  ///   - param2:
  /// RESPONSE
  ///  product was updated (Json data)
  ///
  static const String API_SET_PRODUCT = "set_product";

  ///
  /// REQUEST_PARAMS
  ///   - params: id
  /// RESPONSE
  ///  success / failed
  ///
  static const String API_DELETE_PRODUCT = "delete_product";

  ///
  /// REQUEST_PARAMS
  ///   - params: json data contains user informations
  ///   - param2:
  /// RESPONSE
  ///  user was updated (Json data)
  ///
  static const String API_SET_USER = "set_user";

  ///
  /// REQUEST_PARAMS
  ///   - user_id: int
  ///   - followed_user_id: int
  ///   - is_follow: bool
  /// RESPONSE
  ///  result: true/false (json)
  ///
  static const String API_SET_FOLLOW_USER = "set_follow_user";

  ///
  /// REQUEST_PARAMS
  ///   - user_id: int
  ///   - product_id: int
  ///   - is_favorite: bool
  /// RESPONSE
  ///  result: true/false (json)
  ///
  static const String API_SET_FAVORITE_PRODUCT = "set_favorite_product";

  ///
  /// REQUEST_PARAMS
  ///   - user_id: int
  ///   - product_id: int
  ///   - is_watched: bool
  /// RESPONSE
  ///  result: true/false (json)
  ///
  static const String API_SET_WATCHED_PRODUCT = "set_watched_product";

  ///
  /// REQUEST_PARAMS
  ///   - user_id: int
  ///   - shipping address infos (json)
  /// RESPONSE
  ///  result: true/false (json)
  ///
  static const String API_SET_SHIPPING_ADDRESS = "set_shipping_address";

  ///
  /// REQUEST_PARAMS
  ///   - params: json data contains order informations
  ///   - param2:
  /// RESPONSE
  ///  order was updated (Json data)
  ///
  /// COMMENTS
  ///   - added: 2019/4/8 by ThuanTM
  ///   - server implementation: not yet -> TODO: @Dong
  ///
  static const String API_SET_ORDER = "set_order";

  ///
  /// REQUEST_PARAMS
  ///   - params: order_id
  ///   - param2: status_id
  ///   - param3: user_id
  /// RESPONSE
  ///  order was updated (Json data)
  ///
  /// COMMENTS
  ///   - added: 2019/4/24 by ThuanTM
  ///   - server implementation: not yet -> TODO: @Dong
  ///
  static const String API_SET_ORDER_STATUS = "set_order_status";

  ///
  /// REQUEST_PARAMS
  ///   - params: order_id
  ///   - param2: assessment object data (json)
  /// RESPONSE
  ///  updated assessment object data (json)
  ///
  /// COMMENTS
  ///   - added: 2019/4/24 by ThuanTM
  ///   - server implementation: not yet -> TODO: @Dong
  ///
  static const String API_SET_ORDER_ASSESSMENT = "set_order_assessment";

  ///
  /// REQUEST_PARAMS
  ///   - params: json data contains message informations
  ///   - param2: related_product_id, id of product, -> TODO: @Dat - please send notification for other user're commenting on this product
  ///   - param3: related_order_id, id of order, -> TODO: @Dat - please send notification for other user're commenting on this order
  /// RESPONSE
  ///  message was updated (Json data)
  ///
  static const String API_SET_MESSAGE = "set_message";

  ///
  /// REQUEST_PARAMS
  ///   - params: product_id
  /// RESPONSE
  ///  message was updated (Json data)
  ///
  static const String API_GET_MESSAGE = "get_message";

  ///
  /// REQUEST_PARAMS
  ///   - params: json data contains user-seller informations
  /// RESPONSE
  ///  List of User -> (done)
  ///
  static const String API_GET_ALL_SELLER = "get_all_seller";

  static const String API_GET_PROVINCE = "get_province";
  static const String API_GET_DISTRICT = "get_district";
  static const String API_GET_WARD = "get_ward";
  static const String API_GET_STREET = "get_street";

  /// REQUEST_PARAMS
  ///   - user_id:
  /// RESPONSE
  ///  objects (User('id','avatar','introduction','name'))
  ///
  static const String API_GET_USER = "get_user";

  /// REQUEST_PARAMS
  ///   - user_id:
  /// RESPONSE
  ///  objects (User('id','avatar','introduction','name'))
  ///
  static const String API_VERIFY_PHOTO = "verify_photo";

  /// REQUEST_PARAMS
  ///   - user_id:
  /// RESPONSE
  ///  objects (User('id','avatar','introduction','name'))
  ///
  static const String API_VERIFY_ADDRESS = "verify_address";

  static const String API_GET_YOUR_NOTIFICATION = "get_your";

  static const String API_GET_SYSTEM_NOTIFICATION = "get_system";

  static const String API_GET_PHOTO_VERIFIED = "get_photo_verified";

  static const String API_GET_UNREAD_COUNT = "count_unread";

  static const String API_SET_UNREAD = "set_unread";

  static const String API_CREATE_PAYMENT = "create_payment";

  static const String API_GET_PAYMENT = "get_payment";

  static const String API_GET_REVENUE_CHART = "get_revenue_chart";

  static const String API_GET_REVENUE = "get_revenue";

  static const String API_GET_FOLLOW_USER = "get_follow_user";

  static const String API_GET_PRODUCT_CATEGORY = "get_product_category";

  static const String API_GET_PRODUCT = "get_product";

  static const String API_REQUEST_WITHDRAWAL = "request_withdrawal";

  static const String API_SAVE_SEARCH_HISTORY = "save_search_history";

  static const String API_DELETE_SHIPPING_ADDRESS = "delete_shipping_address";

}
