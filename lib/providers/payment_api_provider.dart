import 'dart:async';

import 'package:flutter_rentaza/models/Sale/payment.dart';
import 'package:flutter_rentaza/models/Sale/revenue.dart';
import 'package:simple_logger/simple_logger.dart';

import 'api_list.dart';
import 'api_provider.dart';

class PaymentApiProvider extends ApiProvider {
  final SimpleLogger _logger = SimpleLogger()
    ..mode = LoggerMode.print
    ..setLevel(Level.INFO, includeCallerInfo: true);

  PaymentApiProvider() : super() {
    apiUrlSuffix = "/payment";
  }

  Future<bool> createPayment(Map params) async {
    _logger.info("[updatePayment] params=$params");
    var result = await this.postData(ApiList.API_CREATE_PAYMENT, params);
    _logger.info("[updatePayment] response=$result");

    if (result != null && result['status'] == 'success') return true;
    return false;
  }

  Future<Revenue> getRevenue(Map params) async {
    var result = await this.getData(ApiList.API_GET_REVENUE, params);
    if (result != null) return Revenue.fromJSON(result);
    return null;
  }

  Future<List<RevenueChart>> getRevenueChart(Map params) async {
    var result = await this.getData(ApiList.API_GET_REVENUE_CHART, params);
    if (result != null)
      return List<RevenueChart>.from(
          result.map((e) => RevenueChart.fromJSON(e)));
    return null;
  }

  Future<List<Payment>> getPayment(Map params) async {
    var result = await this.getData(ApiList.API_GET_PAYMENT, params);
    if (result != null)
      return List<Payment>.from(result.map((e) => Payment.fromJSON(e)));
    return [];
  }

  Future<int> requestWithdrawal(Map params) async {
    var result = await this.postData(ApiList.API_REQUEST_WITHDRAWAL, params);
    if (result != null && result['status']){
      return result['money_account_id'];
    }
    return 0;
  }
}
