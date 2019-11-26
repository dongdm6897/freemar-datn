import 'package:flutter_rentaza/models/Product/attribute_type.dart';
import 'package:flutter_rentaza/models/Sale/ads.dart';
import 'package:flutter_rentaza/models/User/money_account.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_logger/simple_logger.dart';
import '../models/Product/payment_method.dart';
import '../models/Product/product_status.dart';
import '../models/Product/ship_pay_method.dart';
import '../models/Product/ship_provider.dart';
import '../models/Product/ship_time_estimation.dart';
import '../models/Sale/assessment_type.dart';
import '../models/Sale/commerce_fee.dart';
import '../models/Sale/order_status.dart';
import '../models/User/user.dart';
import '../providers/repository.dart';
import 'bloc_provider.dart';

class AppBloc implements BlocBase {
  final SimpleLogger _logger = SimpleLogger()
    ..mode = LoggerMode.print
    ..setLevel(Level.INFO, includeCallerInfo: true);

  // Singleton object
  static final AppBloc _singleton = AppBloc._internal();

  factory AppBloc() => _singleton;

  AppBloc._internal();

  // Private
  final _repository = Repository();
  Map<String, String> _links = new Map<String, String>();

  // Private master datas
  int _defaultGridColumnNumber = 2;
  double _chargeMinAmount = 50000;
  String fcmToken;
  List<ProductStatus> _productStatuses = new List<ProductStatus>();
  List<ShipProvider> _shipProviders = new List<ShipProvider>();
  List<ShipPayMethod> _shipPayMethods = new List<ShipPayMethod>();
  List<ShipTimeEstimation> _shipTimeEstimation = new List<ShipTimeEstimation>();
  List<PaymentMethod> _paymentMethods = new List<PaymentMethod>();

  List<OrderStatus> _orderStatuses = new List<OrderStatus>();
  List<AssessmentType> _assessmentTypes = new List<AssessmentType>();
  List<CommerceFee> _commerceFees = new List<CommerceFee>();
  List<BankType> _bankType = List<BankType>();

  List<Bank> _bankList = List<Bank>();

  List<Ads> _adsList = List<Ads>();

  List<String> _chatSuggestions = [];

  // Attributes
  List<AttributeType> _attributeTypes = new List<AttributeType>();
  Map<String, List<AttributeType>> _attributeTypeGroups =
      new Map<String, List<AttributeType>>();

  // Global used variable
  User _loginUser;

  // Getter
  Map<String, String> get links => _links;

  int get defaultGridColumnNumber => _defaultGridColumnNumber;

  double get chargeMinAmount => _chargeMinAmount;

  List<ProductStatus> get productStatuses => _productStatuses;

  List<ShipProvider> get shipProviders => _shipProviders;

  List<ShipPayMethod> get shipPayMethods => _shipPayMethods;

  List<ShipTimeEstimation> get shipTimeEstimation => _shipTimeEstimation;

  List<PaymentMethod> get paymentMethods => _paymentMethods;

  List<OrderStatus> get orderStatuses => _orderStatuses;

  List<AssessmentType> get assessmentTypes => _assessmentTypes;

  List<CommerceFee> get commerceFees => _commerceFees;

  List<BankType> get bankTypes => _bankType;

  List<Bank> get banks => _bankList;

  List<Ads> get ads => _adsList;

  List<String> get chatSuggestions => _chatSuggestions;

  double get defaultCommerceFee => getCommerceFee();

  User get loginUser => _loginUser;

  List<AttributeType> get attributeTypes => _attributeTypes;

  Map<String, List<AttributeType>> get attributeTypeGroups =>
      _attributeTypeGroups;

  PublishSubject eventBackground = PublishSubject();

  Stream get streamEvent => eventBackground.stream;

  Sink get eventSink => eventBackground.sink;

  // Setter
  setLoginUser(User user) {
    _loginUser = user;
  }

  setLogoutUser() {
    _loginUser = null;
  }

  //TODO: Need implement for category & sub-category!!!
  double getCommerceFee({int categoryId}) {
    _logger.info('categoryId=$categoryId');
    return _commerceFees
        .firstWhere(
            (e) =>
                ((e.validTo?.compareTo(DateTime.now()) ?? 0)) >= 0 &&
                ((categoryId ?? 0) == (e.categoryId ?? 0)),
            orElse: () => null)
        ?.value;
  }

  // Load all master data in here
  getMasterDatas() async {
    var masterDatasJson = await _repository.getMasterDatas();

    // Get configs
    _defaultGridColumnNumber =
        masterDatasJson["app_configs"]["default_grid_column_number"];

    _chargeMinAmount =
        masterDatasJson["app_configs"]["charge_min_amount"].toDouble();

    // Get commerce fees
    _commerceFees = new List<CommerceFee>.from(
        masterDatasJson["commerce_fees"].map((e) => CommerceFee.fromJSON(e)));

    // Get links
    _links = new Map<String, String>.fromIterable(masterDatasJson["links"],
        key: (item) => item["name"].toString(), value: (item) => item["link"]);

    // Get product statuses
    _productStatuses = new List<ProductStatus>.from(
        masterDatasJson["product_status"]
            .map((e) => ProductStatus.fromJSON(e)));

    // Get shipping_method
    _shipProviders = new List<ShipProvider>.from(
        masterDatasJson["ship_provider"].map((e) => ShipProvider.fromJSON(e)));

    // Get shipping_payment_method
    _shipPayMethods = new List<ShipPayMethod>.from(
        masterDatasJson["ship_pay_method"]
            .map((e) => ShipPayMethod.fromJSON(e)));

    // Get shipping time estimation
    _shipTimeEstimation = new List<ShipTimeEstimation>.from(
        masterDatasJson["ship_time_estimation"]
            .map((e) => ShipTimeEstimation.fromJSON(e)));

    // Get payment methods
    _paymentMethods = new List<PaymentMethod>.from(
        masterDatasJson["payment_method"]
            .map((e) => PaymentMethod.fromJSON(e)));

    // Get order statuses
    _orderStatuses = new List<OrderStatus>.from(
        masterDatasJson["order_status"].map((e) => OrderStatus.fromJSON(e)));

    // Get assessment types
    _assessmentTypes = new List<AssessmentType>.from(
        masterDatasJson["assessment_type"]
            .map((e) => AssessmentType.fromJSON(e)));

    // Bank type
    _bankType = new List<BankType>.from(
        masterDatasJson["bank_type"].map((e) => BankType.fromJSON(e)));

    // Bank
    _bankList = new List<Bank>.from(
        masterDatasJson["bank_list"].map((e) => Bank.fromJSON(e)));

    //Ads
    _adsList = new List<Ads>.from(
        masterDatasJson["ads_list"]?.map((e) => Ads.fromJSON(e)));

    // Chat suggestions
    _chatSuggestions =
        new List<String>.from(masterDatasJson["chat_suggestions"] ?? []);

    // Attribute
    _attributeTypes = new List<AttributeType>.from(
        masterDatasJson["attribute_types"]
            .map((e) => AttributeType.fromJSON(e)));
    _attributeTypes.forEach((e) {
      var groupName = e.group ?? 'ungroup';
      var items = _attributeTypeGroups[groupName] ?? [];
      items.add(e);
      _attributeTypeGroups[groupName] = items;
    });
  }

  OrderStatus getStatusObjectById(List<int> ids) {
    return this
        .orderStatuses
        .firstWhere((s) => ids.contains(s.id), orElse: () => null);
  }

  AttributeType getAttributeTypeByCode(String code) {
    if (code == null) return null;

    return this
        ._attributeTypes
        .firstWhere(((c) => c.id == code), orElse: () => null);
  }

  String searchShipPlaceFromAddress() {
//    return _shippingPlaceList.firstWhere((e) => address?.contains(e) ?? false,
//            orElse: () => null) ??
//        _shippingPlaceList[0];
    ///TO DO - get location
    return "Hà Nội";
  }

  @override
  void dispose() {
    _singleton.dispose();
    eventBackground.close();
  }
}
