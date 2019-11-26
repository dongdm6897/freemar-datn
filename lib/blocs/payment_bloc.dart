import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/bloc_provider.dart';
import 'package:flutter_rentaza/models/Sale/order.dart';
import 'package:flutter_rentaza/models/Sale/payment.dart';
import 'package:flutter_rentaza/models/Sale/revenue.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/providers/repository.dart';
import 'package:flutter_rentaza/ui/pages/payment/bb_vnpay_payment.dart';
import 'package:rxdart/rxdart.dart';

class PaymentBloc implements BlocBase {
  final _repository = Repository();
  final _appBloc = AppBloc();

  //Revenue
  PublishSubject<List<RevenueChart>> _revenueController =
      PublishSubject<List<RevenueChart>>();

  Stream<List<RevenueChart>> get streamRevenue => _revenueController.stream;

  Sink<List<RevenueChart>> get revenueSink => _revenueController.sink;

  //Payment
  BehaviorSubject<List<Payment>> _paymentController =
      BehaviorSubject<List<Payment>>();

  Stream<List<Payment>> get streamPayment => _paymentController.stream;

  Sink<List<Payment>> get paymentSink => _paymentController.sink;

  Future<bool> getPayment(Map params) async {
    List<Payment> results = await _repository.getPayment(params);
    if (results != null && results.length > 0) {
      var lastList = _paymentController.value;
      if (lastList != null)
        paymentSink.add(lastList + results);
      else
        paymentSink.add(results);
      return true;
    }
    return false;
  }

  Future<bool> createPayment(Payment payment, String accessToken) {
    var params = payment.toJson();
    params['access_token'] = accessToken;
    return _repository.createPayment(params);
  }

  Future<bool> getRevenueChart(Map params) async {
    List<RevenueChart> results = await _repository.getRevenueChart(params);
    if (results != null) {
      if(!_revenueController.isClosed) revenueSink.add(results);
      return true;
    }
    return false;
  }

  Future<Revenue> getRevenue(Map params) {
    return _repository.getRevenue(params);
  }

  Future<int> requestWithdrawal(
      int moneyAccountId,
      String bankAccount,
      int bankId,
      String bankBranch,
      String bankName,
      double amount,
      double fee,
      String accessToken) async {
    Map params = Map();
    Payment payment = Payment(
      amount: amount,
      fee: fee,
      comment: 'Request a Withdrawal',
      paymentTypeId: PaymentTypeEnum.REQUEST_WITHDRAWAL,
      currency: "vn",
    );
    params['money_account'] = {
      'money_account_id': moneyAccountId,
      'bank_id': bankId,
      'bank_branch': bankBranch,
      'account_name': bankName,
      'account_number': bankAccount
    };
    params['payment'] = payment.toJson();
    params['access_token'] = accessToken;

    int returnMoneyAccountId = await _repository.requestWithdrawal(params);

    if (returnMoneyAccountId != 0) {
      payment.createdAt = DateTime.now();
      payment.updatedAt = DateTime.now();
      var lastList = _paymentController.value;
      if (lastList != null)
        paymentSink.add(lastList + [payment]);
      else
        paymentSink.add([payment]);
      return returnMoneyAccountId;
    }
    return 0;
  }

  Future<bool> doPaymentWithBbAccount(Order order) async {
    //TODO: Implement this proc
    var payment = Payment(
      amount: order.totalAmount,
      fee: order.paymentFee ?? 0,
      comment: 'Payment order with BB account',
      paymentTypeId: PaymentTypeEnum.BUYER_PAY,
      currency: "vn",
      orderId: order.id,
      paymentMethodId: PaymentMethodEnum.BB_ACCOUNT,
    );

    var createPayment =
        await this.createPayment(payment, _appBloc.loginUser.accessToken);
    if (createPayment) {
//       Update order
      order.statusObj =
          _appBloc.getStatusObjectById([OrderStatusEnum.ORDER_PAID]);
      _appBloc.loginUser.balance =
          _appBloc.loginUser.balance - order.totalAmount;
      return true;
    }
    return false;
  }

  Future<bool> doPaymentWithVNPay(BuildContext context, Order order) async {
    var payment = Payment(
      amount: order.totalAmount,
      fee: order.paymentFee ?? 0,
      comment: 'Payment order with VNPay',
      paymentTypeId: PaymentTypeEnum.BUYER_PAY,
      currency: "vn",
      orderId: order.id,
      paymentMethodId: PaymentMethodEnum.VNPAY,
    );
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => new BbVNPayPaymentScreen(
                title: 'Online Payment by VNPay',
                payment: payment,
                bankType: order.paymentMethodObj.bankType.code)));
    if ((result ?? false) == true) {
      var createPayment =
          await this.createPayment(payment, _appBloc.loginUser.accessToken);
      if (createPayment) {
//       Update order
        order.statusObj =
            _appBloc.getStatusObjectById([OrderStatusEnum.ORDER_PAID]);
        _appBloc.loginUser.balance =
            _appBloc.loginUser.balance - order.totalAmount;
        return true;
      }
      return false;
    }

    return null;
  }

  @override
  void dispose() {
    _paymentController.close();
    _revenueController.close();
  }
}
