import 'dart:async';

import 'package:flutter_rentaza/models/Sale/order.dart';
import 'package:simple_logger/simple_logger.dart';

import 'api_list.dart';
import 'api_provider.dart';

class OrderApiProvider extends ApiProvider {
  final SimpleLogger _logger = SimpleLogger()
    ..mode = LoggerMode.print
    ..setLevel(Level.INFO, includeCallerInfo: true);

  OrderApiProvider() : super() {
//    mockupDataPath = 'assets/json/order.json';
//    apiBaseUrl = 'http://139.162.25.146/api/V1/order';
    apiUrlSuffix = "/order";
  }

  Future<int> updateOrder(Order order, String accessToken) async {
    var params = order.toJson();
    params['access_token'] = accessToken;
    _logger.info("[updateOrder] params=$params");
    var result = await this.postData(ApiList.API_SET_ORDER, params);
    _logger.info("[updateOrder] response=$result");

    if (result['status'] == 'success') return result['order_id'];
    return 0;
  }

  Future<bool> updateOrderStatus(Map params) async {
    _logger.info("[updateOrderStatus] params=$params");
    var result = await this.postData(ApiList.API_SET_ORDER_STATUS, params);
    _logger.info("[updateOrderStatus] response=$result");

    if (result['status'] == 'success') return true;
    return false;
  }

  Future<int> updateOrderAssessment(Map params) async {
    _logger.info("[updateOrderAssessment] params=$params");
    var result = await this.postData(ApiList.API_SET_ORDER_ASSESSMENT, params);
    _logger.info("[updateOrderAssessment] response=$result");

    if (result['status'] == 'success') {
      return result['id'];
    }
    return null;
  }
}
