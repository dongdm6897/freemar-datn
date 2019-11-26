import 'package:flutter_rentaza/generated/i18n.dart';

///
/// Define const value for working with master data values.
/// This value need equal to ID of status inside master data
///


class OrderStatusEnum {
  static const int EMPTY = 1;
  static const int ORDER_REQUESTED = 2;
  static const int ORDER_APPROVED = 3;
  static const int ORDER_PAID = 4;
  static const int SHIP_REQUESTED = 5;
  static const int SHIP_STATUS = 6;
  static const int SHIP_FAILED = 7;
  static const int SHIP_DONE = 8;
  static const int ASSESSMENT = 9;
  static const int RETURN_REQUESTED = 10;
  static const int RETURN_CONFIRM = 11;
  static const int RETURN_SHIPPING = 12;
  static const int RETURN_FAILED = 13;
  static const int RETURN_DONE = 14;
  static const int TRANSACTION_FINISHED = 15;
  static const int TRANSACTION_CANCELLED = 16;
  static const int ORDER_REJECTED = 17;
  List<String> orderStatusName = [
    S.current.empty,
    S.current.order_requested,
    S.current.order_approved,
    S.current.order_paid,
    S.current.ship_requested,
    S.current.ship_status,
    S.current.ship_failed,
    S.current.ship_done,
    S.current.assessment,
    S.current.return_requested,
    S.current.return_confirm,
    S.current.return_shipping,
    S.current.return_failed,
    S.current.return_done,
    S.current.transaction_finished,
    S.current.transaction_cancelled,
    S.current.order_rejected
  ];


}

class ProductStatusEnum {
  static const int NEW = 1;
  static const int NEW_UNBOXED = 2;
  static const int UNUSED = 3;
  static const int NO_NOTICEABLE_DIRTY = 4;
  static const int SLIGHTLY_DIRTY = 5;
  static const int DIRTY = 6;
  static const int OVERALL_BAD = 7;
  List<String> productStatusName = [
    S.current.new_product,
    S.current.new_unboxed,
    S.current.unused,
    S.current.no_noticeable_dirty,
    S.current.slightly_dirty,
    S.current.dirty,
    S.current.overall_bad
  ];
}

class AssessmentTypeEnum {
  static const int GOOD = 1;
  static const int NORMAL = 2;
  static const int SLOW_SHIPPING = 3;
  static const int SLOW_PAYING = 4;
  static const int WRONG_DESCRIPTION = 5;
  static const int FAKE_GOODS = 6;

}

class ShipPayMethodEnum {
  static const int PAY_WHEN_ORDER = 1;
  static const int PAY_WHEN_RECEIVE = 2;
  static const int FREE_SHIP = 3;
  List<String> shipPayMethodName = [
    S.current.pay_when_order,
    S.current.pay_when_receive,
    S.current.free_ship
  ];
}

class ShipProviderEnum {
//  static const int VNPOST = 1;
//  static const int DHL = 2;
  static const int SUPERSHIP = 1;
  static const int GHN = 2;
//  static const int GRAB = 5;
  static const int GIAO_TAN_NOI = 3;
  static const int TU_DEN_LAY = 4;
}

class ShippingStatusEnum {
  static const int PENDING = 1;
  static const int PICK_UP = 2;
  static const int PICKED_UP = 3;
  static const int DELIVERING = 4;
  static const int DELIVERED = 5;
  static const int PICKUP_FAILED = 6;
  static const int DELIVER_FAILED = 7;
  List<String> shippingStatusName = [
    S.current.pending,
    S.current.pick_up,
    S.current.picked_up,
    S.current.delivering,
    S.current.delivered,
    S.current.pickup_failed,
    S.current.deliver_failed
  ];
}

class PaymentMethodEnum {
  static const int BB_ACCOUNT = 1;
  static const int VNPAY = 2;
//  static const int ATM = 3;
//  static const int CREDIT_CARD = 4;
}

class BankTypeEnum {
  static const int VNBANK = 1;
  static const int INTCARD = 2;
}

class UserStatus {
  static const int INACTIVE = 1;
  static const int ACTIVE = 2;
  static const int SNS = 3;
  static const int SIMPLE = 4;
  static const int MEDIUM_WAITING_FOR_VERIFICATION = 5;
  static const int MEDIUM = 6;
  static const int HIGH_WAITING_FOR_VERIFICATION = 7;
  static const int HIGH = 8;
  static const int BLOCKED = 9;
}

class AttributeTypeEnum {
  static const int COLOR = 1;
  static const int SIZE_CLOTHES = 2;
  static const int SIZE_SHOES = 3;
  static const int SPEED_CPU = 4;
  static const int SIZE_HDD = 5;
// TODO: Add mores
}

class AttributeTypeGroupEnum {
  static const String COLOR = 'color';
  static const String SIZE = 'size';
  static const String SPEED = 'speed';
// TODO: Add mores
}

class NotificationTypeEnum {
  static const int PRODUCT_COMMENT = 1;
  static const int ORDER_CHAT = 2;
  static const int ORDER = 3;
  static const int SYSTEM = 4;
  static const int SHOW_HIDE_BOTTOM_BAR = 5;
}

class PaymentTypeEnum {
  static const int BUYER_PAY = 1;
  static const int REFUND = 2;
  static const int PAY_FOR_SELLER = 3;
  static const int DEPOSIT = 4;
  static const int WITHDRAW = 5;
  static const int REQUEST_WITHDRAWAL = 6;
}

class AdsTypeEnum {
  static const int BANNER = 1;
}
