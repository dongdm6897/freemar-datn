import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rentaza/models/Sale/payment.dart';
import 'package:intl/intl.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BbVNPayPaymentScreen extends StatefulWidget {
  final String title;
  final Payment payment;
  final String bankType;

  BbVNPayPaymentScreen({this.title, this.payment, this.bankType});

  @override
  _BbVNPayPaymentScreenState createState() => new _BbVNPayPaymentScreenState();
}

class _BbVNPayPaymentScreenState extends State<BbVNPayPaymentScreen> {
  final SimpleLogger _logger = SimpleLogger()..mode = LoggerMode.print;

  WebViewController _webViewController;
  bool _isLoading = true;

  // VNPay settings
  final String _paymentGateway =
      'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  final String _merchant = 'MO02NHVT';
  final String _secureSecret = 'PVUHZZQBODSARODSHXEBHKCMYFMKZKZG';
  final String _version = '2.0.0';
  final String _command = 'pay';
  final String _currency = 'VND';
  final String _locale = 'vn';
  final String _returnUrl = 'http://139.162.25.146/api/V1/payment/return';
  final String _ipAddr = '139.162.25.146';

  @override
  void initState() {
    _isLoading = true;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _buildCheckoutUrl() {
    var time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

    // Create params
    var paramz = {
      'vnp_Version': _version,
      'vnp_Command': _command,
      'vnp_TmnCode': _merchant,
      'vnp_Locale': _locale,
      'vnp_BankCode': widget.bankType,
      'vnp_CurrCode': _currency,
      'vnp_TxnRef': widget.payment.orderId?.toString() ?? '$time',
      'vnp_OrderInfo': widget.payment.comment ?? 'Baibai Order',
      'vnp_OrderType': 'fashion',
      'vnp_Amount':
          ((widget.payment.amount ?? 100000) * 100).floor().toString(),
      'vnp_ReturnUrl': _returnUrl,
      'vnp_IpAddr': _ipAddr,
      'vnp_CreateDate': time
    };
    paramz.removeWhere((k, v) => (v ?? '').length == 0);

    // Calculate md5 hash (without encoding)
    var secureCode = [];
    paramz.forEach((k, v) => {secureCode.add('$k=$v')});
    secureCode.sort(); //Importance for creating right md5 hash code
    var secureCodeString = secureCode.join('&');
    var md5 = _createMd5Hash(_secureSecret + secureCodeString);

    // Update md5
    paramz['vnp_SecureHashType'] = 'MD5';
    paramz['vnp_SecureHash'] = md5;

    // Create url (with encoding)
    var paramArr = [];
    paramz.forEach((k, v) =>
        paramArr.add('${Uri.encodeComponent(k)}=${Uri.encodeComponent(v)}'));
    var request = '$_paymentGateway?${paramArr.join("&")}';
    _logger.info('request: $request');
    return request;
  }

  String _createMd5Hash(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  bool _checkResponse(String data) {
    //TODO: Need check more carefully!
    var tmp = data ?? '';
    return tmp.startsWith(_returnUrl) && tmp.contains('vnp_ResponseCode=00');
  }

  @override
  Widget build(BuildContext context) {
    final request = _buildCheckoutUrl();
    _logger.info('checkoutUrl: $request');

    // handle the backbutton behaviour inside the webview
    return WillPopScope(
      onWillPop: () async {
        if (await _webViewController.canGoBack()) {
          _webViewController.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: IndexedStack(
            index: _isLoading ? 1 : 0,
            children: <Widget>[
              WebView(
                  initialUrl: request,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController wbController) {
                    _logger.info('onWebViewCreated.');
                    _webViewController = wbController;
                  },
                  javascriptChannels: <JavascriptChannel>[
                    _toasterJavascriptChannel(context),
                  ].toSet(),
                  onPageFinished: (String url) {
                    _logger.info('onPageFinished. url=$url');

//                    _webViewController.evaluateJavascript(""
//
//                        "document.getElementById('cardNumber').value='111111111';"
//                        "document.getElementById('cardDate').value='09/09';"
//                        "document.getElementById('cardDate').focus();"
//                        "document.getElementById('cardHolder').value='NGUYEN VAN DAT'");
                    setState(() {
                      _isLoading = false;
                    });

                    // Check payment is finished or not?
                    if (_checkResponse(url)) {
                      Navigator.pop(context, true);
                    }
                  }),
              Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
                color: Colors.white,
              )
            ],
          )),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
}
