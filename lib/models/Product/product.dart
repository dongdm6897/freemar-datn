import 'package:flutter_rentaza/models/User/shipping_address.dart';

import '../Sale/order.dart';
import '../User/user.dart';
import '../root_object.dart';
import 'attribute.dart';
import 'brand.dart';
import 'category.dart';
import 'message.dart';
import 'ship_pay_method.dart';
import 'ship_provider.dart';

class Product extends RootObject {
  int id;
  String name;
  String representImage;
  double price;
  double originalPrice;
  double commerceFee;
  double newProductReferPrice;
  double newProductReferLink;
  double weight;

  String description;
  ShippingAddress shippingFrom;
  int quantity;
  int numberOfComments;
  int numberOfFavorites;
  bool isSoldOut;
  bool isPublic;
  bool
      isConfirmRequired; // Require buyer confirm & get approval of seller before doing payment

  int statusId;

  List<String> referenceImageLinks;
  List<String> tags;
  List<Message> commentMessageObjs;

  List<Attribute> attributeObjs; // Addition attributes

  User ownerObj;
  Brand brandObj;
  Category categoryObj;
  ShipPayMethod shippingPaymentMethodObj;
  ShipProvider shipProviderObj;
  int shipTimeEstimationId;
  Order inOrderObj;

  bool isOrdering;

  Product(
      {this.id,
      this.name,
      this.representImage,
      this.price,
      this.originalPrice,
      this.commerceFee,
      this.newProductReferPrice,
      this.newProductReferLink,
      this.weight,
      this.tags,
      this.description,
      this.shippingFrom,
      this.quantity,
      this.isSoldOut = false,
      this.isPublic = false,
      this.isConfirmRequired = false,
      this.ownerObj,
      this.brandObj,
      this.numberOfComments,
      this.numberOfFavorites,
      this.categoryObj,
      this.attributeObjs,
      this.statusId,
      this.commentMessageObjs,
      this.referenceImageLinks,
      this.shipProviderObj,
      this.shippingPaymentMethodObj,
      this.shipTimeEstimationId,
      this.isOrdering = false,
      this.inOrderObj,
      DateTime createdAt,
      DateTime updatedAt})
      : super(createdAt: createdAt, updatedAt: updatedAt);

  @override
  factory Product.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      var messages = json["messages"]?.map((e) => Message.fromJSON(e));
      var attrs = json["attributes"]?.map((e) => Attribute.fromJSON(e));

      var product = new Product(
          id: json["id"],
          name: json["name"],
          description: json["description"],
          shippingFrom: ShippingAddress.fromJSON(json["shipping_from"]),
          //TODO: add this field
          representImage: json["image"],
          ownerObj: User.fromJSONSIMPLE(json["owner"]),
          brandObj: Brand.fromJSON(json["brand"]),
          categoryObj: Category.fromJSON(json["category"]),
          isPublic: json["is_public"] ?? false,
          isSoldOut: json["is_sold_out"] ?? false,
          isConfirmRequired: json["is_confirm_required"] ?? false,
          price: json["price"]?.toDouble(),
          originalPrice: json["original_price"]?.toDouble(),
          commerceFee: json["commerce_fee"]?.toDouble(),
          newProductReferPrice: json["new_product_refer_price"]?.toDouble(),
          newProductReferLink: json["new_product_refer_link"]?.toDouble(),
          weight: json['weight'].toDouble() ?? 0.0,
          statusId: json["status_id"],
          referenceImageLinks:
              (json["reference_image_links"] as String)?.split(","),
          tags: (json["tags"] as String)?.split(","),
          commentMessageObjs:
              (messages != null) ? new List<Message>.from(messages) : null,
          numberOfComments: json["number_of_comments"],
          numberOfFavorites: json["number_of_favorites"],
          attributeObjs:
              (attrs != null) ? new List<Attribute>.from(attrs) : null,
          quantity: json["quantity"],
          shipProviderObj: ShipProvider.fromJSON(json["ship_provider"]),
          shippingPaymentMethodObj:
              ShipPayMethod.fromJSON(json["ship_pay_method"]),
          shipTimeEstimationId: json["ship_time_estimation_id"],
          isOrdering: json["is_ordering"] ?? false,
          inOrderObj: json["in_order"] != null
              ? Order.fromJSON(json["in_order"])
              : null,
          createdAt: DateTime.parse(json['created_at']),
          updatedAt: DateTime.parse(json['updated_at']));

      return product;
    }

    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'shipping_from_id': shippingFrom?.id ?? null,
        'image': representImage,
        'owner_id': ownerObj?.id ?? null,
        'brand_id': brandObj?.id ?? null,
        'category_id': categoryObj?.id ?? null,
        'is_public': isPublic,
        'is_confirm_required': isConfirmRequired,
        'price': price,
        'commerce_fee': commerceFee,
        'original_price': originalPrice,
        'weight': weight,
        'new_product_refer_link': newProductReferLink,
        'status_id': statusId,
        'reference_image_links': referenceImageLinks?.join(",") ?? null,
        'tags': tags?.join(",") ?? null,
        'attributes': attributeObjs?.map((e) => e.toJson())?.toList() ?? null,
        "quantity": quantity ?? 1,
        "ship_provider_id": shipProviderObj?.id ?? null,
        "ship_pay_method_id": shippingPaymentMethodObj?.id ?? null,
        "ship_time_estimation_id": shipTimeEstimationId,
      };
}
