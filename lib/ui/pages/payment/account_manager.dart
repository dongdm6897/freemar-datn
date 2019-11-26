import 'package:async/async.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/payment_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Sale/payment.dart';
import 'package:flutter_rentaza/models/Sale/revenue.dart';
import 'package:flutter_rentaza/models/User/money_account.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/ui/pages/payment/bb_vnpay_payment.dart';
import 'package:flutter_rentaza/ui/pages/payment/money_account_selector.dart';
import 'package:flutter_rentaza/ui/pages/utils/help_screen.dart';
import 'package:flutter_rentaza/ui/widgets/dropdown.dart' as CustomDropdown;
import 'package:flutter_rentaza/utils/currency_input_formatter.dart';
import 'package:flutter_rentaza/utils/custom_style.dart';
import 'package:flutter_rentaza/utils/no_data.dart';
import 'package:flutter_rentaza/utils/string_utils.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class AccountManagerPage extends StatefulWidget {
  @override
  _AccountManagerPageState createState() => _AccountManagerPageState();
}

class _AccountManagerPageState extends State<AccountManagerPage> {
  AppBloc _appBloc = AppBloc();
  User _user;
  MoneyAccount _moneyAccount;
  PaymentBloc _paymentBloc;
  TextEditingController _tcAmount = new TextEditingController();
  final _saving = ValueNotifier(true);
  final _showMore = ValueNotifier(true);
  DateTime today = DateTime.now();
  int _selectDropdown = 0;
  int _page = 1;
  int _pageSize = 10;

  DateTime currentMonth, twelveMonthsAgo;
  final mapMonth = Map<int, double>();

  final _asyncMemo = AsyncMemoizer();

  Bank _selectBank;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _user = _appBloc.loginUser;
    if (_user.moneyAccounts != null && _user.moneyAccounts.length > 0) {
      _moneyAccount = _user.moneyAccounts[0];
    }
    _tcAmount.text = '100000';
    _paymentBloc = PaymentBloc();

    currentMonth = DateTime(today.year, today.month, 31);
    twelveMonthsAgo = DateTime(today.year, today.month - 12, 1);

    _paymentBloc.getRevenueChart({
      'start_date': DateFormat("yyyy-MM-dd").format(twelveMonthsAgo),
      'end_date': DateFormat("yyyy-MM-dd").format(currentMonth),
      'payment_type_id': PaymentTypeEnum.PAY_FOR_SELLER,
      'access_token': _user.accessToken
    }).then((value) {
      _saving.value = false;
    });

    _paymentBloc.getPayment({
      'page': _page,
      'page_size': _pageSize,
      'access_token': _user.accessToken,
    }).then((value) {
      if (!value) _showMore.value = false;
    });

    int month = currentMonth.month;
    for (int i = 0; i < 12; i++) {
      if (month >= 12) {
        month = 1;
        mapMonth[month] = 0;
      } else {
        month = month + 1;
        mapMonth[month] = 0;
      }
    }
    mapMonth[currentMonth.month] = 0;

    super.initState();
  }

  @override
  void dispose() {
    _paymentBloc.dispose();
    _tcAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lang = S.of(context);

    return ValueListenableBuilder(
        valueListenable: _saving,
        builder: (context, value, _) {
          return ModalProgressHUD(
            inAsyncCall: value,
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text("Account Manager"),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.help_outline),
                    onPressed: () {
                      var route = MaterialPageRoute(
                          builder: (BuildContext context) => new HelpScreen(
                              title: 'HELP: About account manager screen',
                              url: AppBloc().links["help1"]));
                      Navigator.of(context).push(route);
                    },
                  )
                ],
              ),
              body: Builder(
                  builder: (context) => new SingleChildScrollView(
                          child: Column(
                        children: <Widget>[
                          _buildAccountInfoPart(context),
                          StreamBuilder(
                              stream: _paymentBloc.streamRevenue,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<RevenueChart>> snapshot) {
                                if (snapshot.hasData) {
                                  return _buildRevenue(context, snapshot.data);
                                } else {
                                  return _buildRevenue(context, null);
                                }
                              }),
                          _buildPaymentHistory(context),
                        ],
                      ))),
            ),
          );
        });
  }

  Future<MoneyAccount> _selectBankAccount(BuildContext context) async {
    MoneyAccount ret = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MoneyAccountSelector();
      },
    );

    return ret;
  }

  Widget _buildAccountInfoPart(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String bankAccount = "";
    int bankId = 0;
    String bankBranch = "";
    String bankName = "";
    double amount = 0.0;
    double fee = 0.0;

    TextEditingController _bankAccountController = TextEditingController();
    TextEditingController _bankBranchController = TextEditingController();
    TextEditingController _bankNameController = TextEditingController();

    if (_moneyAccount != null) {
      _bankAccountController.text = _moneyAccount.number;
      _bankBranchController.text = _moneyAccount.branch;
      _selectBank = _appBloc.banks
          .firstWhere((b) => b.id == _moneyAccount.bankId, orElse: () => null);
      _bankNameController.text = _moneyAccount.name;
    }

    return Container(
        decoration: _containerDecoration(),
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Text(
              "Account Information",
              style: CustomTextStyle.labelInformation(context),
            ),
            Divider(),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Row(children: <Widget>[
                Icon(Icons.attach_money),
                Padding(padding: EdgeInsets.all(5.0)),
                Text("Balance"),
                Spacer(),
                Text(formatCurrency(_user.balance),
                    style: CustomTextStyle.textPrice(context)),
              ]),
            ),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Tài khoản của bạn được tích hợp sẵn ví điện tử baibai giúp cho việc mua bán hàng trở nên nhanh chóng và tiết kiệm. \t1. Bạn có thể chọn thanh toán bằng ví baibai khi mua hàng với chi phí chuyển tiền miễn phí không giới hạn lần chuyển. \t2. Bạn cũng có thể nạp thêm tiền, hoặc rút tiền từ ví baibai về tài khoản ngân hàng bất cứ khi nào bạn muốn.",
                  style: CustomTextStyle.textExplainNormal(context),
                )),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.0),
                      child: FlatButton(
                        color: Theme.of(context).accentColor,
                        child: Text(
                          "Nạp tiền vào ví",
                          style: Theme.of(context)
                              .textTheme
                              .subhead
                              .copyWith(color: Colors.white),
                        ),
                        onPressed: () {
                          _handleChargeMoneyAccount(context);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.0),
                      child: FlatButton(
                        color: Theme.of(context).accentColor,
                        child: Text(
                          "Rút tiền",
                          style: Theme.of(context)
                              .textTheme
                              .subhead
                              .copyWith(color: Colors.white),
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return Form(
                                      key: _formKey,
                                      child: SimpleDialog(
                                        contentPadding: EdgeInsets.all(15.0),
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Flexible(
                                                child: TextFormField(
                                                  decoration: InputDecoration(
                                                    labelText: "Số tài khoản",
                                                    //fillColor: Colors.green
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  validator: (value) {
                                                    if (value.isEmpty)
                                                      return "You can't leave this empty";
                                                    return null;
                                                  },
                                                  onSaved: (value) {
                                                    bankAccount =
                                                        value.toString();
                                                  },
                                                  controller:
                                                      _bankAccountController,
                                                ),
                                                flex: 10,
                                              ),
                                              Flexible(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    _moneyAccount =
                                                        await _selectBankAccount(
                                                            context);
                                                    if (_moneyAccount != null) {
                                                      _bankAccountController
                                                              .text =
                                                          _moneyAccount.number;
                                                      _bankBranchController
                                                              .text =
                                                          _moneyAccount.branch;
                                                      _selectBank = _appBloc
                                                          .banks
                                                          .firstWhere(
                                                              (b) =>
                                                                  b.id ==
                                                                  _moneyAccount
                                                                      .bankId,
                                                              orElse: () =>
                                                                  null);
                                                      _bankNameController.text =
                                                          _moneyAccount.name;
                                                    }
                                                  },
                                                  child: Icon(
                                                      Icons.arrow_drop_down),
                                                ),
                                                flex: 1,
                                              )
                                            ],
                                          ),
                                          CustomDropdown
                                              .DropdownButtonHideUnderline(
                                                  child: CustomDropdown
                                                      .DropdownButtonFormField<
                                                          Bank>(
                                            decoration: InputDecoration(
                                                labelText: "Ngân hàng"),
                                            value: _selectBank,
                                            items: _appBloc.banks
                                                .map((val) => CustomDropdown
                                                        .DropdownMenuItem<Bank>(
                                                      value: val,
                                                      child: Text(
                                                        val.name,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ))
                                                .toList(),
                                            onChanged: (val) {
                                              setState(() {
                                                _selectBank = val;
                                              });
                                            },
                                            validator: (value) {
                                              if (value == null)
                                                return "You can't leave this empty";
                                              return null;
                                            },
                                            onSaved: (value) {
                                              bankId = value.id;
                                            },
                                          )),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              labelText: "Chi nhánh",
                                              //fillColor: Colors.green
                                            ),
                                            keyboardType: TextInputType.text,
                                            validator: (value) {
                                              if (value.isEmpty)
                                                return "You can't leave this empty";
                                              return null;
                                            },
                                            onSaved: (value) {
                                              bankBranch = value;
                                            },
                                            controller: _bankBranchController,
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              labelText: "Tên tài khoản",
                                              //fillColor: Colors.green
                                            ),
                                            keyboardType: TextInputType.text,
                                            validator: (value) {
                                              if (value.isEmpty)
                                                return "You can't leave this empty";
                                              return null;
                                            },
                                            onSaved: (value) {
                                              bankName = value;
                                            },
                                            controller: _bankNameController,
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              labelText: "Số tiền",
                                              //fillColor: Colors.green
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value.isEmpty)
                                                return "You can't leave this empty";
                                              return null;
                                            },
                                            onSaved: (value) {
                                              amount = double.tryParse(value);
                                            },
                                          ),
                                          Container(height: 15.0),
                                          FlatButton(
                                            onPressed: () async {
                                              if (_formKey.currentState
                                                  .validate()) {
                                                _formKey.currentState.save();
                                                Navigator.of(context).pop();
                                                _saving.value = true;
                                                if ((amount + fee) <=
                                                    _user.balance) {
                                                  bool duplicate = false;
                                                  for (MoneyAccount moneyAcc
                                                      in _user.moneyAccounts) {
                                                    if (moneyAcc.bankId ==
                                                            bankId &&
                                                        moneyAcc.number ==
                                                            bankAccount) {
                                                      duplicate = true;
                                                      break;
                                                    }
                                                  }
                                                  int returnMoneyAccountId =
                                                      await _paymentBloc
                                                          .requestWithdrawal(
                                                              duplicate
                                                                  ? _moneyAccount
                                                                      .id
                                                                  : 0,
                                                              bankAccount,
                                                              bankId,
                                                              bankBranch,
                                                              bankName,
                                                              amount,
                                                              fee,
                                                              _user
                                                                  .accessToken);
                                                  _saving.value = false;
                                                  if (returnMoneyAccountId !=
                                                      0) {
                                                    if (!duplicate) {
                                                      _user.moneyAccounts.add(
                                                          MoneyAccount(
                                                              id:
                                                                  returnMoneyAccountId,
                                                              number:
                                                                  bankAccount,
                                                              name: bankName,
                                                              bankId: bankId,
                                                              branch:
                                                                  bankBranch));
                                                    }
                                                    _user.balance =
                                                        _user.balance -
                                                            (amount + fee);
                                                    _scaffoldKey.currentState
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                "Yêu cầu rút tiền thành công")));
                                                  } else
                                                    _scaffoldKey.currentState
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                "Yêu cầu rút tiền thất bại")));
                                                } else {
                                                  _saving.value = false;
                                                  _scaffoldKey.currentState
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              "Tài khoản không đủ tiền để thực hiện")));
                                                }
                                              }
                                            },
                                            child: Text(
                                              "Request",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            color: Colors.red,
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                );
                              });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 15.0),
          ],
        ));
  }

  Widget _buildRevenueGraphPart(
      BuildContext context, List<RevenueChart> revenues) {
    List<charts.Series<OrdinalSales, String>> seriesList;
    List<OrdinalSales> datas = <OrdinalSales>[];
    if (revenues != null && revenues.length > 0) {
      Map<int, double> temp = Map.from(mapMonth);
      for (int i = 0; i < revenues.length; i++) {
        if (temp.containsKey(revenues[i].month))
          temp[revenues[i].month] = revenues[i].amount;
      }
      temp.forEach((k, v) {
        datas.add(
          OrdinalSales('T$k', v),
        );
      });
      seriesList = [
        new charts.Series<OrdinalSales, String>(
          id: 'Sales',
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
          domainFn: (OrdinalSales sales, _) => sales.month,
          measureFn: (OrdinalSales sales, _) => sales.money,
          data: datas,
        )
      ];
    } else {
      mapMonth.forEach((k, v) {
        datas.add(
          OrdinalSales('T$k', v),
        );
      });
      seriesList = [
        new charts.Series<OrdinalSales, String>(
          id: 'Sales',
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
          domainFn: (OrdinalSales sales, _) => sales.month,
          measureFn: (OrdinalSales sales, _) => sales.money,
          data: datas,
        )
      ];
    }

    return SizedBox(height: 400.0, child: SimpleBarChart(seriesList));
  }

  Widget _buildRevenue(BuildContext context, List<RevenueChart> revenues) {
    final lang = S.of(context);

    return Container(
        decoration: _containerDecoration(),
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
        child: Column(
          children: <Widget>[
            Divider(),
            FutureBuilder(
              future: _asyncMemo.runOnce(() {
                return _paymentBloc
                    .getRevenue({'access_token': _user.accessToken});
              }),
              builder: (context, snapshot) {
                Revenue revenue = snapshot.hasData ? snapshot.data : null;
                return Column(children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Doanh thu"),
                      Text(revenue?.revenue?.toString() ?? "0",
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Sản phẩm đã mua"),
                      Text(revenue?.quantityBought?.toString() ?? "0",
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Sản phẩm bán được"),
                      Text(revenue?.quantitySold?.toString() ?? "0",
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Sản phẩm hoàn trả"),
                      Text(revenue?.quantityRefunded?.toString() ?? "0",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold))
                    ],
                  )
                ]);
              },
            ),
            Divider(
              color: Colors.red,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                isExpanded: true,
                value: _selectDropdown,
                onChanged: (int newValue) async {
                  _saving.value = true;
                  switch (newValue) {
                    case 0:
                      _selectDropdown = 0;
                      bool res = await _paymentBloc.getRevenueChart({
                        'start_date':
                            DateFormat("yyyy-MM-dd").format(twelveMonthsAgo),
                        'end_date':
                            DateFormat("yyyy-MM-dd").format(currentMonth),
                        'payment_type_id': PaymentTypeEnum.PAY_FOR_SELLER,
                        'access_token': _user.accessToken
                      });
                      if (res) _saving.value = false;
                      break;
                    case 1:
                      _selectDropdown = 1;
                      bool res = await _paymentBloc.getRevenueChart({
                        'start_date':
                            DateFormat("yyyy-MM-dd").format(twelveMonthsAgo),
                        'end_date':
                            DateFormat("yyyy-MM-dd").format(currentMonth),
                        'payment_type_id': PaymentTypeEnum.BUYER_PAY,
                        'access_token': _user.accessToken
                      });
                      if (res) _saving.value = false;
                      break;
                    default:
                      break;
                  }
                },
                items: [
                  DropdownMenuItem<int>(
                    value: 0,
                    child: Text("Sell"),
                  ),
                  DropdownMenuItem<int>(
                      value: 1,
                      child: Text(
                        "Buy",
                      )),
                ],
              )),
            ),
            Divider(
              color: Colors.red,
            ),
            _buildRevenueGraphPart(context, revenues)
          ],
        ));
  }

  Widget _buildPaymentHistory(BuildContext context) {
    return Container(
      decoration: _containerDecoration(),
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Lịch sử giao dịch",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          StreamBuilder(
              stream: _paymentBloc.streamPayment,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Payment>> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.length > 0) {
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext content, int index) {
                          Payment payment = snapshot.data[index];
                          return ListTile(
                            title: Text(
                              payment.comment ?? "",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(DateFormat("yyyy-MM-dd hh:mm:ss")
                                .format(payment.createdAt)),
                            trailing: Text(
                              formatCurrency(payment.amount),
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        });
                  }
                }
                return noData();
              }),
          ValueListenableBuilder(
              valueListenable: _showMore,
              builder: (context, value, _) {
                if (value)
                  return Align(
                    alignment: Alignment.bottomRight,
                    child: FlatButton(
                        onPressed: () async {
                          _saving.value = true;
                          _page = _page + 1;
                          bool res = await _paymentBloc.getPayment({
                            'page': _page,
                            'page_size': _pageSize,
                            'access_token': _user.accessToken
                          });
                          _saving.value = false;
                          if (!res) _showMore.value = false;
                        },
                        child: Text("Xem thêm")),
                  );
                return SizedBox();
              })
        ],
      ),
    );
  }

  BoxDecoration _containerDecoration({Color borderColor = null}) {
    return BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20.0,
          ),
        ],
        border: (borderColor != null)
            ? Border.all(
                color: borderColor,
                width: 2.0,
              )
            : null);
  }

  Future<bool> _handleChargeMoneyAccount(BuildContext context) async {
    Future<bool> doChargeMoneyByVNPay(double amount,
        {bool useKnownWithDrawAccount = false}) async {
      // Create payment object for order
      var payment = Payment(
        amount: amount,
        comment: 'Nạp tiền vào tài khoản',
        currency: "vn",
        paymentTypeId: PaymentTypeEnum.DEPOSIT,
        paymentMethodId: PaymentMethodEnum.VNPAY,
      );

      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => new BbVNPayPaymentScreen(
                    title: 'Online Payment by VNPay',
                    payment: payment,
                  )));
      if ((result ?? false) == true) {
        var createPayment = await _paymentBloc.createPayment(
            payment, _appBloc.loginUser.accessToken);
        if (createPayment) {
          setState(() {
            _user.balance = _user.balance + amount;
          });
          return true;
        }
      }
      return false;
    }

    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(20.0),
          title: const Text('Nạp tiền vào ví baibai'),
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                  labelText:
                      'Nhập số tiền (>= ${formatCurrency(_appBloc.chargeMinAmount)})',
                  hintText: "100,000"),
              keyboardType: TextInputType.number,
              style: CustomTextStyle.textPrice(context),
              textAlign: TextAlign.center,
              controller: _tcAmount,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
                CurrencyInputFormatter()
              ],
            ),
            Divider(),
            Material(
                child: InkWell(
                    child: Container(
                        height: 80.0,
                        padding: EdgeInsets.all(8.0),
                        margin: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 1.0),
                            borderRadius: BorderRadius.circular(5.0)),
                        child:
                            Text('Chọn tài khoản ngân hàng (qua cổng VNPay)')),
                    onTap: () async {
                      var amount =
                          double.tryParse(_tcAmount.text.replaceAll(',', ''));
                      if (amount < _appBloc.chargeMinAmount) {
                        var flushbar = Flushbar(
                          title: "Information",
                          message:
                              "Số tiền nộp tối thiểu là ${formatCurrency(_appBloc.chargeMinAmount)}",
                          duration: Duration(seconds: 5),
                          backgroundColor: Colors.red,
                        );
                        await flushbar.show(context);
                        return;
                      }

                      var ret = await doChargeMoneyByVNPay(amount);
                      Navigator.pop(context, ret);
                    })),
          ],
        );
      },
    );
  }
}

class SimpleBarChart extends StatelessWidget {
  final List<charts.Series<OrdinalSales, String>> seriesList;
  final bool animate;

  SimpleBarChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,
    );
  }
}

class OrdinalSales {
  final String month;
  final double money;

  OrdinalSales(this.month, this.money);
}
