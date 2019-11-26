import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/payment_bloc.dart';
import 'package:flutter_rentaza/models/Product/ship_provider_service.dart';
import 'package:flutter_rentaza/models/Sale/assessment.dart';
import 'package:flutter_rentaza/models/Sale/order.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shipping_plugin/shipping_plugin.dart';
import 'package:shipping_plugin/src/models/super_ship.dart';
import 'package:shipping_plugin/src/models/ghn.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:shipping_plugin/src/models/order/super_ship_order.dart';
import 'package:shipping_plugin/src/models/order/ghn_order.dart';

import '../providers/repository.dart';
import 'bloc_provider.dart';

class OrderBloc implements BlocBase {
  final _repository = Repository();
  final _appBloc = AppBloc();
  PaymentBloc paymentBloc = PaymentBloc();

  GlobalConfiguration globalConfiguration = GlobalConfiguration()
    ..loadFromAsset("app_settings");

  //TODO: Need implement for category & sub-category!!!
  Future calculateOrderFee(Order order, ShipProviderService shipProviderService,
      bool includeShippingFee) async {
    bool isShipping = true;
    // Get sell price (if sell price isn't set, return original price of product)
    order.sellPrice = order.productObj.price ?? 0.0;

    // Get commerce fee
    order.commerceFee = order.productObj.commerceFee ?? 0.0;

    // Get shipping fee
    if (order.shippingAddress != null) {
      ShippingPlugin shippingPlugin = ShippingPlugin();

      switch (order.productObj.shipProviderObj.id) {
        case ShipProviderEnum.SUPERSHIP:
          SuperShip superShip = new SuperShip(
            receiverProvince: order.shippingAddress.province.name,
            receiverDistrict: order.shippingAddress.district.name,
            senderProvince: order.productObj.shippingFrom.province.name,
            senderDistrict: order.productObj.shippingFrom.district.name,
            weight: order.productObj.weight.toString(),
            value: order.sellPrice.toString(),
          );
          var res = await shippingPlugin.calculateFee(superShip);
          if (res != null && res['results'] != null) {
            order.shippingFee = res['results'][0]['fee'].toDouble();
//            order.shippingFee = 10000;
          } else {
            isShipping = false;
            Fluttertoast.showToast(
                msg: S.current.address_not_supported,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIos: 2,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);

            order.shippingFee = 0.0;
          }
          break;

        case ShipProviderEnum.GHN:
          GHN ghn = new GHN(
              token: "5da6c7fdc14ebd74c3684082",
              fromDistrictID: order.productObj.shippingFrom.district.ghnCode,
              toDistrictID: order.shippingAddress.district.ghnCode,
              weight: order.productObj.weight.toInt(),
              serviceID: shipProviderService.serviceCode);

          var res = await shippingPlugin.calculateFee(ghn);
          if (res != null) {
            order.shippingFee = res['data']['CalculatedFee'].toDouble();
          } else {
            isShipping = false;
            Fluttertoast.showToast(
                msg: S.current.address_not_supported,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIos: 2,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            order.shippingFee = 0.0;
          }
          break;

        default:
          break;
      }
    }

    // Get payment fee
//    order.paymentFee = (order.paymentMethodObj?.fee ?? 0.0) * order.sellPrice;

    // Get discout TODO: implement later
    order.discount ??= 0;

    // Calculate total amount
    order.totalAmount = order.sellPrice +
        order.paymentFee -
        order.discount +
        (includeShippingFee ? order.shippingFee : 0);

    return isShipping;
  }

  Future<int> updateOrder(Order order) async {
    return await _repository.updateOrder(
        order, _appBloc.loginUser?.accessToken);
  }

  Future<bool> updateOrderStatus(Map params) async {
    return await _repository.updateOrderStatus(params);
  }

  Future<Assessment> updateOrderAssessment(
      Assessment assessment,
      int orderStatus,
      int notificationUserId,
      String accessToken,
      double returnShippingFee) async {
    Map params = assessment.toJson();
    params['access_token'] = accessToken;
    params['notification_user_id'] = notificationUserId;
    params['order_status'] = orderStatus;
    params['return_shipping_fee'] = returnShippingFee;
    int assessmentId = await _repository.updateOrderAssessment(params);
    assessment.id = assessmentId;
    return assessment;
  }

  Future getReturnShippingFee(Order order) async {
    if (order.shippingAddress != null) {
      ShippingPlugin shippingPlugin = ShippingPlugin();

      switch (order.productObj.shipProviderObj.id) {
        case ShipProviderEnum.SUPERSHIP:
          SuperShip superShip = new SuperShip(
            receiverProvince: order.productObj.shippingFrom.province.name,
            receiverDistrict: order.productObj.shippingFrom.district.name,
            senderProvince: order.shippingAddress.province.name,
            senderDistrict: order.shippingAddress.district.name,
            weight: order.productObj.weight.toString(),
            value: order.sellPrice.toString(),
          );
          var res = await shippingPlugin.calculateFee(superShip);
          if (res != null) {
            order.returnShippingFee = res['results'][0]['fee'].toDouble();
          } else
            order.returnShippingFee = 0.0;
          break;

        case ShipProviderEnum.GHN:
          GHN ghn = new GHN(
              token: "TokenStaging",
              fromDistrictID: order.shippingAddress.district.ghnCode,
              toDistrictID: order.productObj.shippingFrom.district.ghnCode,
//              fromDistrictID: 1443,
//              toDistrictID: 1452,
              weight: order.productObj.weight.toInt(),
              serviceID: 53319);

          var res = await shippingPlugin.calculateFee(ghn);
          if (res != null) {
            order.returnShippingFee = res['data']['CalculatedFee'].toDouble();
          } else
            order.returnShippingFee = 0.0;
          break;
        default:
          break;
      }
    }
  }

  Future<bool> createShippingOrder(Order _order) async {
    ShippingPlugin shippingPlugin = new ShippingPlugin();

    switch (_order.productObj.shipProviderObj.id) {
      case ShipProviderEnum.SUPERSHIP:
        SuperShipOrder superShipOrder = new SuperShipOrder(
            token:
                "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6Ijk3ODNmMDFkYTg2YWI3YzhjN2NmY2M5NDhjYmFmZjQyZDhlZDZlNjYyN2ExMThhZTVmMTM2MThmZGY3MThlMDdhNDljMTFmZjkzM2NiODI5In0.eyJhdWQiOiIxIiwianRpIjoiOTc4M2YwMWRhODZhYjdjOGM3Y2ZjYzk0OGNiYWZmNDJkOGVkNmU2NjI3YTExOGFlNWYxMzYxOGZkZjcxOGUwN2E0OWMxMWZmOTMzY2I4MjkiLCJpYXQiOjE1NTE5NDI4NjQsIm5iZiI6MTU1MTk0Mjg2NCwiZXhwIjoxNTgzNTY1MjY0LCJzdWIiOiIyMTYyNCIsInNjb3BlcyI6W119.DNDzngK7IGIJI8dib4U_hMQtG_4ZKy30_xwQEjqzza6Jd3cXtnVOFWgrvuUVkDzHG7QpumV6l9NBkGLPhnddgV1ioQ00j4KYEXXi7gyTMn2o2dEe7C8e6hp4n6vXLtHMzNc7MBG2jmbX9GakgCxdmNfTt1ewBnXGex3XVjd_AniNxy6_XIlD3Jw-pGprmSHmq2s1AFhgzw70Eq4nCZfGr194Y7Nw-bGeM26JY0BU2Pf8AcAjDDmvSPB4BbcYdJsVreLNsTN3wWDl-HI6AbTKuhT4D3zST55egFvN-nX2ElZAQxeJ59CgiyxoKBdsJGZx8c1Dg7CzcOGIknPpYzfESmQcT98NM93IaiHwa3OGQeFg8fGfYvk2JlqdA9m-XSNVkRvRsnOJ6OXWnZPxeNVYaKYVq3w_gK5tONI16OWTYQYztWvDjJWjXgBQMMVruqLQuBgoMmWcTctpqSiJK260gU_e6v6eFNBNGXm2a9zk771pic6Dzji1FlwTtURo3iiJFJxc73JRr1ywtO87mNocf_MSzVzraYwi6VEom76eWdB0j3Fl-UUT_Q-4sjZLqh5SqrxZk480Tj-wtC2yFNPj9hN4tmBt1wQNzJFYwnEHBoUPBhiOLotByIaO-cFpJ92x_8K_ri6yc_sVmneY-AozdNBt1nC-zzuT_WUlxZdrR_I",
            pickupPhone: _order.productObj.shippingFrom.phoneNumber,
            pickupAddress: _order.productObj.shippingFrom.address,
            pickupProvince: _order.productObj.shippingFrom.province.name,
            pickupDistrict: _order.productObj.shippingFrom.district.name,
            pickupCommune: _order.productObj.shippingFrom.ward.name,
            name: _order.buyerObj.name,
            phone: _order.shippingAddress.phoneNumber,
            email: _order.buyerObj.email,
            address: _order.shippingAddress.address,
            province: _order.shippingAddress.province.name,
            district: _order.shippingAddress.district.name,
            commune: _order.shippingAddress.ward.name,
            amount: 0,
            value: _order.sellPrice.toInt(),
            weight: _order.productObj.weight.toString(),
            service: _order.productObj.shipProviderObj.shipProviderService
                .firstWhere((p) => p.id == _order.shipProviderServiceId)
                .serviceCode
                .toString(),
            config: "1",
            //Cho xem san pham truoc khi nhan hang
            payer: "1",

            ///ToDo xem lai
            productType: "1",

            ///ToDo
            product: _order.productObj.categoryObj.name.toString());
        var res = await shippingPlugin.createOrder(superShipOrder);
        print(superShipOrder.service);
        print("dongpro$res");
        if (res != null && res['status'] == "Success") {
          _order.providerOrderCode = res['results']['code'];
//          int newOrder = await this.updateOrder(_order);
          int newOrder = await _repository.updateOrder(
              _order, _appBloc.loginUser?.accessToken);

          return newOrder != 0 ? true : false;
        } else {
          Fluttertoast.showToast(
              msg: "Create shipping order failed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          return false;
        }
        break;

      case ShipProviderEnum.GHN:
        GHNOrder ghnOrder = new GHNOrder(
            token: "5da6c7fdc14ebd74c3684082",
            fromDistrictID: _order.productObj.shippingFrom.district.ghnCode,
            fromWardCode: _order.productObj.shippingFrom.ward.ghnCode.toString(),
            toDistrictID: _order.shippingAddress.district.ghnCode,
            toWardCode: _order.shippingAddress.ward.ghnCode.toString(),
//        note: "Tạo ĐH qua API",
//        sealCode: "tem niêm phong",
//        externalCode: "",
            clientContactName: "Giao Hang Nhanh",
            clientContactPhone: _order.productObj.shippingFrom.phoneNumber,
            clientAddress: _order.productObj.shippingFrom.address,
            customerName: _order.buyerObj.name,
            customerPhone: _order.shippingAddress.phoneNumber,
            shippingAddress: _order.shippingAddress.address,
//        coDAmount: 1500000,
            noteCode: "CHOXEMHANGKHONGTHU",
//        insuranceFee: 0,
//        clientHubID: 299650,
            serviceID: _order.productObj.shipProviderObj.shipProviderService
                .firstWhere((p) => p.id == _order.shipProviderServiceId)
                .serviceCode,
//        toLatitude: 1.2343322,
//        ToLongitude: 10.54324322,
//        FromLat: 1.2343322,
//        FromLng: 10.54324322,
//        content: "Test nội dung",
//        couponCode: "",
            weight: _order.productObj.weight.toInt(),
            length: 10,
              width: 10,
            height: 10,
//        checkMainBankAccount: false,
            returnContactName: "Giao Hang Nhanh",
            returnContactPhone: "19001206",
            returnAddress: "70 Lữ Gia",
            returnDistrictID: 1455,
            externalReturnCode: "GHN",
//        isCreditCreate: true,
            affiliateID: 252905);

        var res = await shippingPlugin.createOrder(ghnOrder);
        if (res != null && res['code'] == 1) {
          _order.providerOrderCode = res['data']['OrderCode'];
//          int newOrder = await this.updateOrder(_order);
          int newOrder = await _repository.updateOrder(
              _order, _appBloc.loginUser?.accessToken);

          return newOrder != 0 ? true : false;
        } else {
          Fluttertoast.showToast(
              msg: "Create shipping order failed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          return false;
        }

        break;

      default:
        break;
    }
    return false;
  }

  @override
  void dispose() {
    paymentBloc.dispose();
  }
}
