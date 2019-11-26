import 'package:flutter/material.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/models/User/user.dart';

class PaymentMethodListWidget extends StatefulWidget {
  final double sellPrice;

  const PaymentMethodListWidget({Key key, this.sellPrice}) : super(key: key);
  @override
  _PaymentMethodListWidget createState() => _PaymentMethodListWidget();
}

class _PaymentMethodListWidget extends State<PaymentMethodListWidget> {
  AppBloc _appBloc;
  User _user;

  @override
  void initState() {
    _appBloc = AppBloc();
    _user = _appBloc.loginUser;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(PaymentMethodListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var lang = S.of(context);
    var size = MediaQuery.of(context).size;
    var rootContext = context;

    return SimpleDialog(contentPadding: EdgeInsets.all(10.0), children: <
        Widget>[
      new Row(
        children: <Widget>[
          new Flexible(
              child: Column(
            children: <Widget>[
              Text(
                lang.product_choose_payment_method,
                style: new TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Divider(),
              Container(
                  padding: EdgeInsets.all(5.0),
                  width: size.width * 0.9,
                  height: _appBloc.paymentMethods.length * 220.0,
                  child: ListView.builder(
                      itemCount: _appBloc.paymentMethods.length,
                      itemBuilder: (BuildContext context, int idx) {
                        var item = _appBloc.paymentMethods[idx];
                        if (item.id == PaymentMethodEnum.BB_ACCOUNT) {
                          return ListTile(
                            leading: Image.asset(
                                item.logo ?? 'assets/images/logo.png',
                                height: 32.0,
                                width: 32.0,
                                fit: BoxFit
                                    .cover), // TODO: Use asset image for this icon. Don't need get from internet. @Dong @Dat
                            title: Text(item.name,
                                style: Theme.of(context).textTheme.title),
                            subtitle: Text(
                              item.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle
                                  .copyWith(color: Colors.grey),
                            ),
                            trailing:
                                (_user?.currentPaymentMethodObj?.id == item.id)
                                    ? Icon(Icons.check)
                                    : null,
                            onTap: () async {
                              _user?.currentPaymentMethodObj = item;
                              item.fee = 0;
                              Navigator.pop(rootContext, item);
                            },
                          );
                        } else if (item.id == PaymentMethodEnum.VNPAY) {
                          return ExpansionTile(
                            leading: Image.network(item.logo),
                            title: RichText(
                                text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                  text: item.name,
                                  style: Theme.of(context).textTheme.title),
                              TextSpan(text: '\n'),
                              TextSpan(
                                text: item.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle
                                    .copyWith(color: Colors.grey),
                              ),
                            ])),
                            trailing:
                                (_user?.currentPaymentMethodObj?.id == item.id)
                                    ? Icon(Icons.check)
                                    : null,
                            children: _appBloc.bankTypes
                                .map((b) => ListTile(
                                      title: Text(b.name),
                                      trailing: (_user?.currentPaymentMethodObj
                                                  ?.bankType?.id ==
                                              b.id)
                                          ? Icon(Icons.check)
                                          : null,
                                      onTap: () async {
                                        if (b.id == BankTypeEnum.VNBANK) {
                                          item.fee =
                                              widget.sellPrice * 0.011 + 1650;
                                          item.bankType = b;
                                        } else if (b.id ==
                                            BankTypeEnum.INTCARD) {
                                          item.fee =
                                              widget.sellPrice * 0.0275 + 2500;
                                          item.bankType = b;
                                        }
                                        _user?.currentPaymentMethodObj = item;
                                        Navigator.pop(rootContext, item);
                                      },
                                    ))
                                .toList(),
                          );
                        }
                        return SizedBox();
                      })),
              Divider(),
              Text(
                'Bạn cần lựa chọn cách thức thanh toán. Sử dụng ví baibai là lựa chọn được khuyên dùng vì bạn sẽ không mất chi phí chuyển tiền. Trước khi sử dụng, bạn cần nạp tiền vào ví baibai.',
                style: TextStyle(color: Colors.grey),
              )
            ],
          ))
        ],
      )
    ]);
  }
}
