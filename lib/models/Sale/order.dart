import 'package:flutter_rentaza/models/Product/payment_method.dart';
import 'package:flutter_rentaza/models/Sale/payment.dart';
import 'package:flutter_rentaza/models/User/shipping_address.dart';
import 'package:intl/intl.dart';

import '../Product/product.dart';
import '../User/user.dart';
import '../master_datas.dart';
import '../root_object.dart';
import 'assessment.dart';
import 'order_status.dart';
import 'shipping_status.dart';

class Order extends RootObject {
  int id;

  // Fees
  double sellPrice; // Original price of product
  double commerceFee; // Get from master data
  double shippingFee; // Get from shipping provider
  double paymentFee; // Calculate from payment method & sell price
  double discount;
  double totalAmount;
  double returnShippingFee;

  // Shipping
  ShippingAddress shippingAddress;

  // Datetime
  DateTime shippingDone;
  DateTime returnShippingDone;

  // Related class objects
  List<Payment> paymentObj;
  OrderStatus statusObj;
  int shippingStatusId;
  Product productObj;
  User buyerObj;
  PaymentMethod paymentMethodObj;
  int shipProviderServiceId;
  String providerOrderCode;

//  List<Message> orderChatMessages;
  List<Assessment> orderAssessments;

  // History of statuses
  List<OrderStatus> allOrderStatusObjs;
  List<ShippingStatus> allShippingStatusObjs;

  Order({
    this.id,
    this.sellPrice = 0,
    this.commerceFee = 0,
    this.shippingFee = 0,
    this.returnShippingFee = 0,
    this.paymentFee = 0,
    this.discount = 0,
    this.totalAmount = 0,
    this.shippingAddress,
    this.paymentObj,
    this.statusObj,
    this.shippingStatusId,
    this.allOrderStatusObjs,
    this.allShippingStatusObjs,
    this.productObj,
    this.paymentMethodObj,
    this.buyerObj,
    this.orderAssessments,
    this.shipProviderServiceId,
    this.shippingDone,
    this.returnShippingDone,
    this.providerOrderCode,
    DateTime createdAt,
    DateTime updatedAt,
  }) : super(createdAt: createdAt, updatedAt: updatedAt);

  @override
  factory Order.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      var assessments = json["assessments"]?.map((e) => Assessment.fromJSON(e));
      var statuses = json["all_statuses"]?.map((e) => OrderStatus.fromJSON(e));
      var shippingStatuses =
          json["all_shipping_statuses"]?.map((e) => ShippingStatus.fromJSON(e));
      var payments = json["payment"]?.map((e) => Payment.fromJSON(e));

      double sellPrice = json["sell_price"]?.toDouble();
      double commerceFee = json["commerce_fee"]?.toDouble();
      double shippingFee = json["shipping_fee"]?.toDouble();
      double paymentFee = json["payment_fee"]?.toDouble();
      double discount = json["discount"]?.toDouble();

      return new Order(
          id: json["id"],
          sellPrice: sellPrice,
          commerceFee: commerceFee,
          shippingFee: shippingFee,
          returnShippingFee: json["return_shipping_fee"]?.toDouble(),
          paymentFee: paymentFee,
          discount: discount,
          totalAmount: sellPrice + paymentFee + sellPrice * discount,
          shippingAddress: ShippingAddress.fromJSON(json["shipping_address"]),
          paymentObj: (payments != null) ? List<Payment>.from(payments) : null,
          statusObj: OrderStatus.fromJSON(json["status"]),
          shippingStatusId: json['shipping_status_id'],
          productObj: Product.fromJSON(json["product"]),
          buyerObj: User.fromJSON(json["buyer"]),
          shipProviderServiceId: json['ship_provider_service_id'],
          providerOrderCode: json['provider_order_code'],
          paymentMethodObj: PaymentMethod.fromJSON(json["payment_method"]),
          allOrderStatusObjs:
              (statuses != null) ? new List<OrderStatus>.from(statuses) : null,
          allShippingStatusObjs: (shippingStatuses != null)
              ? new List<ShippingStatus>.from(shippingStatuses)
              : null,
          orderAssessments: (assessments != null)
              ? new List<Assessment>.from(assessments)
              : null,
          createdAt: DateTime.parse(json['created_at']),
          updatedAt: DateTime.parse(json['updated_at']),
          shippingDone: json['shipping_done'] != null
              ? DateTime.parse(json['shipping_done'])
              : null,
          returnShippingDone: json['return_shipping_done'] != null
              ? DateTime.parse(json['return_shipping_done'])
              : null);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sell_price': sellPrice,
        'commerce_fee': commerceFee,
        'payment_fee': paymentFee,
        'shipping_fee': shippingFee,
        'discount': discount,
        'shipping_address_id': shippingAddress.id,
        'status_id': statusObj?.id ?? OrderStatusEnum.EMPTY,
        'shipping_status_id': shippingStatusId,
        'product_id': productObj?.id ?? null,
        'payment_method_id': paymentMethodObj?.id ?? null,
        'shipping_service_id': shipProviderServiceId,
        'buyer_id': buyerObj?.id ?? null,
        'provider_order_code' : providerOrderCode
      };
}
