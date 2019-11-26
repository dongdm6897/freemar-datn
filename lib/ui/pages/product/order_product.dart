import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/order_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Product/payment_method.dart';
import 'package:flutter_rentaza/models/Product/product.dart';
import 'package:flutter_rentaza/models/Product/ship_provider_service.dart';
import 'package:flutter_rentaza/models/Sale/order.dart';
import 'package:flutter_rentaza/models/Sale/order_status.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/ui/pages/product/order_finish.dart';
import 'package:flutter_rentaza/ui/pages/product/product_detail.dart';
import 'package:flutter_rentaza/ui/pages/utils/help_screen.dart';
import 'package:flutter_rentaza/ui/widgets/payment_method_list.dart';
import 'package:flutter_rentaza/ui/widgets/ship_provider_service_list.dart';
import 'package:flutter_rentaza/ui/widgets/shipping_address_list.dart';
import 'package:flutter_rentaza/utils/custom_style.dart';
import 'package:flutter_rentaza/utils/string_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:simple_logger/simple_logger.dart';

class OrderProductPage extends StatefulWidget {
  final Product product;

  OrderProductPage({Key key, this.product}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _OrderProductPageState();
  }
}

class _OrderProductPageState extends State<OrderProductPage> {
  final SimpleLogger _logger = SimpleLogger()
    ..mode = LoggerMode.print
    ..setLevel(Level.INFO, includeCallerInfo: true);

  AppBloc _appBloc;
  Product _product;
  Order _order;
  OrderBloc _orderBloc;
  bool _saving = true;
  ShipProviderService shipProviderService = ShipProviderService();
  bool _includeShippingFee = false;
  bool _buying = true;

  @override
  void initState() {
    _appBloc = AppBloc();
    _orderBloc = OrderBloc();
    _product = widget.product;
    _order = new Order(
        productObj: _product,
        buyerObj: _appBloc.loginUser,
        statusObj: new OrderStatus(id: OrderStatusEnum.EMPTY),
        shippingStatusId: ShippingStatusEnum.PENDING);

    // Set default values for _order
    _appBloc.loginUser.currentPaymentMethodObj ??=
        (_appBloc.paymentMethods?.isNotEmpty ?? false)
            ? _appBloc.paymentMethods.first
            : null;
    _order.paymentMethodObj = _appBloc.loginUser.currentPaymentMethodObj;

    _appBloc.loginUser.currentShippingAddressObj ??=
        (_appBloc.loginUser.shippingAddressObjs?.isNotEmpty ?? false)
            ? _appBloc.loginUser.shippingAddressObjs.first
            : null;

    _order.shippingAddress = _appBloc.loginUser.currentShippingAddressObj;
    if (_order.productObj.shipProviderObj.shipProviderService.length > 0)
      shipProviderService =
          _order.productObj.shipProviderObj.shipProviderService[0];
    _order.shipProviderServiceId = shipProviderService.id;

    _includeShippingFee = _product.shippingPaymentMethodObj?.id ==
        ShipPayMethodEnum.PAY_WHEN_ORDER;

    // Recalculate order informations
    _orderBloc
        .calculateOrderFee(_order, shipProviderService, _includeShippingFee)
        .then((value) {
      if (!value) _buying = false;
      setState(() {
        _saving = false;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _orderBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Builder(
            builder: (context) => new SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      _buildBasicInfoPart(context),
                      _buildSettingShippingPart(context),
                      _buildSettingPaymentPart(context),
                      _buildCommandPart(context)
                    ],
                  ),
                )),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final lang = S.of(context);

    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        lang.order_product,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.help_outline),
          onPressed: () {
            var route = MaterialPageRoute(
                builder: (BuildContext context) => new HelpScreen(
                    title: 'HELP: How to order product on BaiBai',
                    url: _appBloc.links["help3"]));
            Navigator.of(context).push(route);
          },
        )
      ],
    );
  }

  Widget _buildBasicInfoPart(BuildContext context) {
    final lang = S.of(context);

    return new GestureDetector(
      child: new Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20.0,
            ),
          ]),
          padding: EdgeInsets.all(12.0),
          child: new Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 80.0,
                    child: _imageStack(_product.representImage),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Padding(
                          padding: EdgeInsets.all(8.0),
                          child: new Row(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _product.name,
                                    style: new TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _product.brandObj?.name ?? "",
                                    style: new TextStyle(
                                        fontSize: 16.0, color: Colors.grey),
                                  ),
                                  Text(
                                    formatCurrency(_product.price),
                                    style: new TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            ],
                          ))
                    ],
                  ),
                ],
              )
            ],
          )),
      onTap: () {
        var route = MaterialPageRoute(
            builder: (BuildContext context) =>
                ProductDetailPage(product: _product));
        Navigator.of(context).push(route);
      },
    );
  }

  Widget _buildSettingPaymentPart(BuildContext context) {
    final lang = S.of(context);

    return Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20.0,
          ),
        ]),
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              lang.order_payment,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Divider(),
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: GestureDetector(
                    child: Row(
                      children: <Widget>[
                        _createIconText(Icon(Icons.payment), 'Payment method'),
                        SizedBox(
                          width: 150.0,
                          height: 30.0,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: AutoSizeText(
                                _order.paymentMethodObj.toString() ??
                                    lang.type_required,
                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .title
                                    .copyWith(
                                        decoration: TextDecoration.underline)),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _handleSelectPaymentMethod(context);
                    },
                  ),
                ),
                Divider(),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 40.0),
              child: Column(
                children: <Widget>[
                  _createInfoLine(
                      context: context,
                      label: lang.product_pricing,
                      message: formatCurrency(_order.sellPrice)),
                  _createInfoLine(
                      context: context,
                      label: lang.order_pay_fee,
                      message: formatCurrency(_order.paymentFee)),
//                  _createInfoLine(
//                      context: context,
//                      label: 'Commerce fee',
//                      message: formatCurrency(_order.commerceFee)),
                  _includeShippingFee
                      ? _createInfoLine(
                          context: context,
                          label: "Shipping fee",
                          message: formatCurrency(_order.shippingFee))
                      : SizedBox(),
                  Divider(
                    color: Colors.grey.shade200,
                  ),
                ],
              ),
            ),
            _createInfoLine(
                context: context,
                label: lang.order_pay_total_amount,
                icon: Icon(Icons.attach_money),
                message: formatCurrency(_order?.totalAmount),
                messageStyle: CustomTextStyle.textPrice(context)),
          ],
        ));
  }

  Widget _buildSettingShippingPart(BuildContext context) {
    final lang = S.of(context);

    return Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20.0,
          ),
        ]),
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Shipment",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: GestureDetector(
                    child: Wrap(
                      children: <Widget>[
                        _createIconText(
                            Icon(Icons.payment), 'Shipping Address'),
                        Text(
                            _appBloc.loginUser?.currentShippingAddressObj
                                    ?.toString() ??
                                lang.message_not_set,
                            maxLines: 1,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ))
                      ],
                    ),
                    onTap: () => _handleSelectShippingAddress(context),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _createIconText(
                          Icon(Icons.local_shipping), 'Ship Provider'),
                      Text(
                        _order.productObj.shipProviderObj.name ??
                            lang.message_not_set,
                      )
                    ],
                  ),
                ),
                _order.productObj.shipProviderObj.id ==
                            ShipProviderEnum.GIAO_TAN_NOI ||
                        _order.productObj.shipProviderObj.id ==
                            ShipProviderEnum.TU_DEN_LAY
                    ? SizedBox()
                    : Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                _createIconText(
                                    Icon(Icons.local_laundry_service),
                                    'Ship Pay Method'),
                                Text(
                                  _order.productObj.shippingPaymentMethodObj
                                          ?.description
                                          ?.toString() ??
                                      lang.message_not_set,
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10.0),
                            child: GestureDetector(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  _createIconText(
                                      Icon(Icons.room_service), 'Ship Service'),
                                  Text(
                                    shipProviderService.description ??
                                        lang.message_not_set,
                                    style: TextStyle(
                                        decoration: TextDecoration.underline),
                                  )
                                ],
                              ),
                              onTap: () {
                                if (_order.productObj.shipProviderObj.id !=
                                    ShipProviderEnum.SUPERSHIP)
                                  _handleSelectShipProviderService(context);
                              },
                            ),
                          ),
                        ],
                      ),
                _product.shippingPaymentMethodObj?.id ==
                        ShipPayMethodEnum.PAY_WHEN_RECEIVE
                    ? _createInfoLine(
                        context: context,
                        icon: Icon(Icons.card_membership),
                        label: "Shipping fee",
                        message: formatCurrency(_order.shippingFee))
                    : SizedBox()
              ],
            ),
          ],
        ));
  }

  Widget _buildCommandPart(BuildContext context) {
    final lang = S.of(context);

    return Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20.0,
          ),
        ]),
        padding: EdgeInsets.all(12.0),
        margin: EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Expanded(
                child: new FlatButton(
              color: Colors.red,
              child: new Text(
                _order.productObj.isConfirmRequired
                    ? 'Đăng kí mua hàng'
                    : lang.order_product,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.white),
              ),
              onPressed: () {
                if (_buying) {
                  if (_order.paymentMethodObj.id ==
                      PaymentMethodEnum.BB_ACCOUNT) {
                    if (_appBloc.loginUser.balance < _order.totalAmount)
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Account Balance not enough to make a transaction")));
                    else
                      _handleProcessNewOrder(context);
                  } else
                    _handleProcessNewOrder(context);
                } else {
                  Fluttertoast.showToast(
                      msg: "Quận/Huyện này chưa hỗ trợ giao hàng",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIos: 2,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
            ))
          ],
        ));
  }

  Widget _createInfoLine(
      {BuildContext context,
      String label,
      TextStyle labelStyle,
      String message,
      TextStyle messageStyle,
      bool isHorizonal = true,
      Icon icon,
      double padding = 10.0}) {
    return isHorizonal
        ? Padding(
            padding: EdgeInsets.all(padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                icon != null
                    ? _createIconText(icon, label)
                    : Text(label,
                        style: labelStyle ??
                            CustomTextStyle.labelInformation(context)),
                Spacer(),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(message,
                        style:
                            messageStyle ?? Theme.of(context).textTheme.title))
              ],
            ))
        : Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                icon != null
                    ? _createIconText(icon, label)
                    : Text(label,
                        style: labelStyle ??
                            CustomTextStyle.labelInformation(context)),
                Padding(
                    padding:
                        EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(message,
                            style: messageStyle ??
                                Theme.of(context).textTheme.title)))
              ],
            ));
  }

  Widget _createIconText(Icon icon, String text, {TextStyle labelStyle}) {
    return Row(children: <Widget>[
      icon,
      Padding(padding: EdgeInsets.all(5.0)),
      Text(text, style: labelStyle ?? CustomTextStyle.labelInformation(context))
    ]);
  }

  void _handleProcessNewOrder(BuildContext context) async {
    var message = "";
    var errFlag = false;

    // Set saving status
    setState(() {
      _saving = true;
    });

    try {
      // Validate order informations
      if (_order.paymentMethodObj == null || _order.shippingAddress == null) {
        message = 'Please fill required datas correctly.';
        errFlag = true;
        return;
      }
      // Init order status
      _order.statusObj = _appBloc.getStatusObjectById([
        _order.productObj.isConfirmRequired
            ? OrderStatusEnum.ORDER_REQUESTED
            : OrderStatusEnum.ORDER_APPROVED
      ]);

      // Update order then send it to server
      _logger.info('_orderBloc.updateOrder');
      var newOrder = await _orderBloc.updateOrder(_order);
      if (newOrder != 0) {
        _order.createdAt = DateTime.now();
        _order.updatedAt = DateTime.now();
        // If order approved, do payment (Process payment if no need confirm when order product)
        if (_order.statusObj.id == OrderStatusEnum.ORDER_APPROVED) {
          _order.id = newOrder;
          bool createShippingOrder = await _orderBloc.createShippingOrder(_order);
          if (createShippingOrder) {
            // Do payment proc
            bool updatedOrder = false;
            if (_order.paymentMethodObj.id == PaymentMethodEnum.BB_ACCOUNT) {
              updatedOrder =
                  await _orderBloc.paymentBloc.doPaymentWithBbAccount(_order);
            } else if (_order.paymentMethodObj.id == PaymentMethodEnum.VNPAY) {
              updatedOrder = await _orderBloc.paymentBloc
                  .doPaymentWithVNPay(context, _order);
            }

            // Show message with updated order status
            if (updatedOrder &&
                _order.statusObj.id == OrderStatusEnum.ORDER_PAID) {
              message = "Order was created & made payment successful";
            } else {
              message =
                  "Order was created successful, but payment wasn't made. Please do payment after.";
            }
          }else{
            errFlag = true;
          }
        } else {
          message =
              "Order was created but need seller approve for selling. Please wait...";
        }
      } else {
        message = "Order updated failed";
        errFlag = true;
        _logger.info('Order updated failed');
      }
      //TODO: Hard code status for testing

      _logger.info(message);
    } catch (e) {
      message = e.toString();
      errFlag = true;
    } finally {
      // Restore saving state
      setState(() {
        _saving = false;
      });

      if (message != "") {
        Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 2,
            backgroundColor: errFlag ? Colors.red : Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }

      if (!errFlag) {
        var route = MaterialPageRoute(
            builder: (BuildContext context) => OrderFinishPage(order: _order));
        Navigator.of(context)
            .pushAndRemoveUntil(route, (Route<dynamic> route) => false);
      } else if (_order.statusObj.id >= OrderStatusEnum.ORDER_APPROVED) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => new AlertDialog(
            title: new Text('Thông báo'),
            content: new Text(
                'Đơn hàng của bạn đã được cập nhật vào hệ thống. Việc thanh toán chưa được hoàn tất. Tuy nhiên, bạn có thể bỏ qua việc thanh toán tại thời điểm này để thực hiện sau.'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.pop(context, true),
                child: new Text('OK'),
              ),
            ],
          ),
        );
        var route = MaterialPageRoute(
            builder: (BuildContext context) => OrderFinishPage(order: _order));
        Navigator.of(context)
            .pushAndRemoveUntil(route, (Route<dynamic> route) => false);
      }
    }
  }

  _handleSelectShippingAddress(BuildContext context) async {
    _saving = true;
    var ret = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ShippingAddressListWidget(user: _appBloc.loginUser);
      },
    );

    if (ret != null) {
      // Recalculate order informations
      _appBloc.loginUser?.currentShippingAddressObj = ret;
      _order.shippingAddress = ret;
      _orderBloc
          .calculateOrderFee(_order, shipProviderService, _includeShippingFee)
          .then((value) {
        if (!value) _buying = false;
        else _buying = true;
        setState(() {
          _saving = false;
        });
      });
    }
  }

  _handleSelectShipProviderService(BuildContext context) async {
    setState(() {
      _saving = true;
    });
    var ret = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ShipProviderServiceListWidget(
              _product.shipProviderObj.shipProviderService);
        });
    if (ret != null) {
      shipProviderService = ret;
      _order.shipProviderServiceId = shipProviderService.id;
      _orderBloc
          .calculateOrderFee(_order, shipProviderService, _includeShippingFee)
          .then((value) {
        if (!value) _buying = false;
        else _buying = true;
        setState(() {
          _saving = false;
        });
      });
    }
  }

  Widget _imageStack(String img) => CachedNetworkImage(
      imageUrl: img,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error));

  _handleSelectPaymentMethod(BuildContext context) async {
    PaymentMethod ret = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PaymentMethodListWidget(
          sellPrice: _order.sellPrice,
        );
      },
    );

    if (ret != null) {
      // Recalculate order informations
      _order.paymentFee = ret.fee;
      _orderBloc.calculateOrderFee(
          _order, shipProviderService, _includeShippingFee);
      setState(() {
        _order.paymentMethodObj = ret;
      });
    }
  }
}
