import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/message_bloc.dart';
import 'package:flutter_rentaza/blocs/order_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Product/message.dart';
import 'package:flutter_rentaza/models/Product/ship_provider_service.dart';
import 'package:flutter_rentaza/models/Sale/assessment.dart';
import 'package:flutter_rentaza/models/Sale/assessment_type.dart';
import 'package:flutter_rentaza/models/Sale/detail_assessment_type.dart';
import 'package:flutter_rentaza/models/Sale/order.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/providers/repository.dart';
import 'package:flutter_rentaza/ui/pages/product/product_detail.dart';
import 'package:flutter_rentaza/ui/pages/product/search/storage/file_storage.dart';
import 'package:flutter_rentaza/ui/pages/user/profile.dart';
import 'package:flutter_rentaza/ui/pages/utils/help_screen.dart';
import 'package:flutter_rentaza/ui/widgets/bb_segmented_control.dart';
import 'package:flutter_rentaza/ui/widgets/chat_message_list.dart';
import 'package:flutter_rentaza/ui/widgets/payment_method_list.dart';
import 'package:flutter_rentaza/utils/custom_style.dart';
import 'package:flutter_rentaza/utils/string_utils.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:simple_logger/simple_logger.dart';

class OrderDetailPage extends StatefulWidget {
  final Order order;

  OrderDetailPage({Key key, this.order}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _OrderDetailPageState();
  }
}

class _OrderDetailPageState extends State<OrderDetailPage>
    with TickerProviderStateMixin {
  final SimpleLogger _logger = SimpleLogger()..mode = LoggerMode.print;
  AppBloc _appBloc;
  MessageBloc _messageBloc;
  OrderBloc _orderBloc;

  Order _order;
  User _user;

  static const String kNameOrder = "order_register";
  static const String kNamePayment = "order_payment";
  static const String kNameOrderShipping = "order_shipping";
  static const String kNameOrderChecking = "order_checking";
  static const String kNameOrderFinish = "order_finish";
  List<String> _collapsedPanels = <String>[];

  List<AssessmentType> _assessmentTypes = new List<AssessmentType>();

  DetailAssessmentType _detailAssessmentType;
  TextEditingController _textFieldFeedbackController = TextEditingController();

  Map _pagination;
  int _page = 1;
  final _chatMessage = <Message>[];
  ScrollController _scrollController;

  //Animation
  Animation<double> animation;
  AnimationController _controller;

  final FileStorage fileStorage = FileStorage();

  bool _saving = false;

  bool _isBuyer = false;
  List<Asset> images = List<Asset>();

  @override
  void initState() {
    super.initState();
    _appBloc = AppBloc();
    _messageBloc = MessageBloc();
    _orderBloc = OrderBloc();

    _order = widget.order;
    _user = _appBloc.loginUser;
    _assessmentTypes = _appBloc.assessmentTypes;
    _isBuyer = _order.buyerObj.id == _user.id;

    _collapsedPanels.addAll([
      kNameOrder,
      kNamePayment,
      kNameOrderFinish,
      kNameOrderChecking,
      kNameOrderShipping
    ]);

    this.getOrderChat();

    //Animation
    _controller =
        new AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..repeat();
    animation =
        new CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
  }

  @override
  void dispose() {
    _messageBloc.dispose();
    _textFieldFeedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var spacer = Container(color: Colors.transparent, height: 8);
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      appBar: _buildAppBar(context),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Builder(
            builder: (context) => new SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: <Widget>[
                    _buildProductInfoPart(context),
                    spacer,
                    _buildCommerceFlowPart(context),
                  ],
                ))),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.message),
          onPressed: () {
            return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _buildChatChannelPart(context);
                });
          }),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final lang = S.of(context);
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        "Theo dõi đơn hàng",
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.help_outline),
          onPressed: () {
            var route = MaterialPageRoute(
                builder: (BuildContext context) => new HelpScreen(
                      title: 'HELP: How to order product on BaiBai',
                      url: _appBloc.links["help3"],
                    ));
            Navigator.of(context).push(route);
          },
        )
      ],
    );
  }

  Widget _buildProductInfoPart(BuildContext context) {
    final lang = S.of(context);

    return new GestureDetector(
      child: ClipRect(
        child: Banner(
          message: "in order",
          location: BannerLocation.topEnd,
          color: Colors.green,
          child: new Container(
              padding: EdgeInsets.all(10.0),
              color: Colors.white,
              child: Row(children: <Widget>[
                Container(
                  width: 80.0,
                  height: 80.0,
                  child: _imageStack(_order.productObj?.representImage),
                ),
                VerticalDivider(),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _order.productObj?.name ?? "",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: new TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _order.productObj?.brandObj?.name ?? "",
                                  style: new TextStyle(
                                      fontSize: 16.0, color: Colors.grey),
                                ),
                                Text(
                                  formatCurrency(_order.productObj?.price),
                                  style: new TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ])),
        ),
      ),
      onTap: () {
        var route = MaterialPageRoute(
            builder: (BuildContext context) =>
                ProductDetailPage(product: _order.productObj));
        Navigator.of(context).push(route);
      },
    );
  }

  Widget _buildCommerceFlowPart(BuildContext context) {
    final lang = S.of(context);
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(0.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(4.0),
              child: Row(
                children: <Widget>[
                  Text(
                    "Order flow",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Spacer(),
                  Text(
                    "(Bấm các tiêu đề để mở rộng)",
                    style: TextStyle(
                        color: Colors.grey.shade400,
                        fontStyle: FontStyle.italic,
                        fontSize: 10.0),
                  )
                ],
              ),
            ),
            _buildOrderRequestSubPart(context),
            lineProgress(OrderStatusEnum.ORDER_PAID),
            _buildPaymentSubPart(context),
            lineProgress(OrderStatusEnum.SHIP_DONE),
            _buildShippingSubPart(context),
            lineProgress(OrderStatusEnum.ASSESSMENT),
            _buildCheckProductSubPart(context),
            _order.statusObj.id >= OrderStatusEnum.RETURN_REQUESTED &&
                    _order.statusObj.id <= OrderStatusEnum.RETURN_DONE
                ? Column(
                    children: <Widget>[
                      lineProgress(OrderStatusEnum.RETURN_DONE),
                      _buildReturnShipping(context)
                    ],
                  )
                : SizedBox(),
            Container(height: 40)
          ],
        ));
  }

  Widget _buildOrderRequestSubPart(BuildContext context) {
    final lang = S.of(context);
    var isActivePart = _order.statusObj.id < OrderStatusEnum.ORDER_APPROVED;
    var isCompleted = _order.statusObj.id >= OrderStatusEnum.ORDER_APPROVED;
    return Container(
        decoration: _containerDecoration(
            borderColor: isActivePart
                ? Colors.red
                : (isCompleted ? Colors.green : null)),
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Material(
              color: Colors.transparent,
              child: InkWell(
                  child: _createSectionHeader(context,
                      icon: Icons.shopping_basket,
                      title: "Đặt hàng",
                      subtitle: formatDateTimeToString(_order.createdAt),
                      user: _order.buyerObj),
                  onTap: () {
                    if (isCompleted) {
                      setState(() {
                        if (_collapsedPanels.contains(kNameOrder))
                          _collapsedPanels.remove(kNameOrder);
                        else
                          _collapsedPanels.add(kNameOrder);
                      });
                    }
                  }),
            ),
            (isActivePart ||
                    (isCompleted && !_collapsedPanels.contains(kNameOrder)))
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Divider(),
                          Padding(
                            padding: EdgeInsets.only(left: 40),
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
//                                _createInfoLine(
//                                    context: context,
//                                    label: 'Commerce fee',
//                                    message:
//                                        formatCurrency(_order.commerceFee)),
                                _createInfoLine(
                                    context: context,
                                    label: "Shipping fee",
                                    message:
                                        formatCurrency(_order.shippingFee)),
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
                      ),
                      Divider(),
                      _createInfoLine(
                          context: context,
                          label: lang.shipping_address,
                          message: _order.shippingAddress.toString() ?? "",
                          icon: Icon(MdiIcons.home),
                          isHorizonal: false),
                      Divider(),
                      Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            isCompleted
                                ? 'Đặt hàng thành công, bên bán đã đồng ý giao dịch, chờ bên mua chuyển tiền'
                                : 'Đặt hàng chưa thành công, chờ bên bán đồng ý giao dịch',
                            style: CustomTextStyle.textExplainNormal(context),
                          )),
                      (_order.productObj.isConfirmRequired &&
                              isActivePart &&
                              _user.id != _order.buyerObj.id)
                          ? Column(
                              children: <Widget>[
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    RaisedButton(
                                      color: Colors.grey,
                                      child: new Text(
                                        "Từ chối",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subhead
                                            .copyWith(color: Colors.white),
                                      ),
                                      onPressed: !isCompleted
                                          ? () => _handleRejectOrder(context)
                                          : null,
                                    ),
                                    RaisedButton(
                                      color: Colors.red,
                                      child: new Text(
                                        "Đồng ý",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subhead
                                            .copyWith(color: Colors.white),
                                      ),
                                      onPressed: !isCompleted
                                          ? () => _handleApproveOrder(context)
                                          : null,
                                    )
                                  ],
                                )
                              ],
                            )
                          : const SizedBox()
                    ],
                  )
                : Container(),
          ],
        ));
  }

  Widget _buildPaymentSubPart(BuildContext context) {
    final lang = S.of(context);
    var isActivePart = _order.statusObj.id >= OrderStatusEnum.ORDER_APPROVED &&
        _order.statusObj.id < OrderStatusEnum.ORDER_PAID;
    var isCompleted = _order.statusObj.id >= OrderStatusEnum.ORDER_PAID;

    return Container(
        decoration: _containerDecoration(
            borderColor: isActivePart
                ? Colors.red
                : (isCompleted ? Colors.green : Colors.red)),
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Material(
              color: Colors.transparent,
              child: InkWell(
                  child: _createSectionHeader(context,
                      icon: Icons.attach_money,
                      title: "Payment",
                      subtitle: _order.paymentObj != null &&
                              _order.paymentObj.length > 0
                          ? formatDateTimeToString(_order.paymentObj
                              .firstWhere((payment) =>
                                  payment.paymentTypeId ==
                                  PaymentTypeEnum.BUYER_PAY)
                              ?.createdAt)
                          : "",
                      user: _order.buyerObj),
                  onTap: () {
                    if (isCompleted) {
                      setState(() {
                        if (_collapsedPanels.contains(kNamePayment))
                          _collapsedPanels.remove(kNamePayment);
                        else
                          _collapsedPanels.add(kNamePayment);
                      });
                    }
                  }),
            ),
            ((!isActivePart || isCompleted) &&
                    _collapsedPanels.contains(kNamePayment))
                ? Container()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Divider(),
                      _createInfoLine(
                          context: context,
                          label: lang.product_choose_payment_method,
                          message: "",
                          icon: Icon(Icons.payment),
                          isHorizonal: false),
                      isActivePart
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    child: Text(
                                        _user.currentPaymentMethodObj
                                                ?.toString() ??
                                            "Chưa chọn",
                                        style:
                                            CustomTextStyle.textLink(context)),
                                    onTap: () {
                                      if (_isBuyer)
                                        _handleSelectPaymentMethod(context);
                                      else
                                        Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "Người bán sẽ thanh toán")));
                                    },
                                  )),
                            )
                          : Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                  _order.paymentMethodObj.name.toString(),
                                  style: CustomTextStyle.textLink(context)),
                            ),
                      Divider(),
                      Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            isCompleted
                                ? (_user.id == _order.buyerObj.id)
                                    ? "Sản phẩm đã được thanh toán.Chờ người bán gửi hàng"
                                    : "Sản phẩm đã được thanh toán.Chờ bên shipping đến lấy hàng"
                                : 'Sản phẩm chưa được thanh toán.',
                            style: CustomTextStyle.textExplainNormal(context),
                          )),
                    ],
                  )
          ],
        ));
  }

  Widget _buildShippingSubPart(BuildContext context) {
    final lang = S.of(context);
    bool isActivePart = _order.statusObj.id >= OrderStatusEnum.ORDER_PAID &&
        _order.statusObj.id < OrderStatusEnum.SHIP_DONE;
    bool isCompleted = _order.statusObj.id >= OrderStatusEnum.SHIP_DONE;
    Widget shippingStatusWidget = _shippingStatus(context, isCompleted);

    return Container(
        decoration: _containerDecoration(
            borderColor: isCompleted ? Colors.green : Colors.red),
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Material(
              color: Colors.transparent,
              child: InkWell(
                  child: _createSectionHeader(context,
                      icon: Icons.local_shipping,
                      title: 'Ship hàng',
                      subtitle: formatDateTimeToString(_order.shippingDone),
                      user: _order.productObj?.ownerObj),
                  onTap: () {
                    if (isCompleted) {
                      setState(() {
                        if (_collapsedPanels.contains(kNameOrderShipping))
                          _collapsedPanels.remove(kNameOrderShipping);
                        else
                          _collapsedPanels.add(kNameOrderShipping);
                      });
                    }
                  }),
            ),
            (isActivePart ||
                    (isCompleted &&
                        !_collapsedPanels.contains(kNameOrderShipping)))
                ? Column(children: <Widget>[
                    Divider(),
                    _createInfoLine(
                        context: context,
                        label: lang.shipping_address,
                        message: _order.shippingAddress.toString() ?? "",
                        icon: Icon(MdiIcons.home),
                        isHorizonal: false),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                      child: _createIconText(
                          Icon(Icons.person_pin), lang.product_ship_provider),
                    ),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 30.0, right: 10.0, top: 10.0),
                        child: Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  _order.productObj.shipProviderObj?.name ?? "",
                                  style: Theme.of(context).textTheme.title),
                            ),
                          ],
                        )),
                    Container(height: 15.0),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                            child: Container(
                          child: Text(
                            'Trạng thái ship hàng',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          padding: EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8.0)),
                          margin: EdgeInsets.all(10.0),
                        )),
                      ],
                    ),
                    shippingStatusWidget
                  ])
                : Container()
          ],
        ));
  }

  Widget _buildCheckProductSubPart(BuildContext context) {
    final lang = S.of(context);
    var size = MediaQuery.of(context).size;
    bool isActivePart = _order.statusObj.id >= OrderStatusEnum.SHIP_DONE &&
        _order.statusObj.id <= OrderStatusEnum.ASSESSMENT;

    bool _assessed = false;

    Assessment _assessment = Assessment();

    if (_order.orderAssessments != null) {
      for (int i = 0; i < _order.orderAssessments.length; i++) {
        if (_order.orderAssessments[i].userId == _user.id) {
          _assessed = true;
          _detailAssessmentType =
              _order.orderAssessments[i].detailAssessmentType;
          _assessment = _order.orderAssessments[i];
          break;
        }
      }
    }

    return Container(
        decoration: _containerDecoration(
            borderColor: _assessed ? Colors.green : Colors.red),
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Material(
              color: Colors.transparent,
              child: InkWell(
                  child: _createSectionHeader(context,
                      icon: Icons.assignment_turned_in,
                      title: "Assessment",
                      subtitle: _order.orderAssessments != null &&
                              _order.orderAssessments.length > 0
                          ? formatDateTimeToString(_order.orderAssessments
                              .firstWhere((ass) => ass.userId == _user.id,
                                  orElse: () => null)
                              ?.createdAt)
                          : "",
                      user: _order.buyerObj),
                  onTap: () {
                    if (_assessed ||
                        _order.statusObj.id >= OrderStatusEnum.RETURN_CONFIRM) {
                      setState(() {
                        if (_collapsedPanels.contains(kNameOrderChecking))
                          _collapsedPanels.remove(kNameOrderChecking);
                        else
                          _collapsedPanels.add(kNameOrderChecking);
                      });
                    }
                  }),
            ),
            (isActivePart ||
                    ((!_isBuyer || _assessed) &&
                        !_collapsedPanels.contains(kNameOrderChecking)))
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: _createIconText(
                                Icon(Icons.favorite), "Feedback"),
                          ),
                          BbSegmentedControl(
                              selectedChanged: (AssessmentType assessmentType,
                                  DetailAssessmentType
                                      detailAssessmentType) async {
                                if (detailAssessmentType != null) {
                                  _detailAssessmentType = detailAssessmentType;
                                } else {
                                  _detailAssessmentType = assessmentType
                                      .detailAssessmentTypes
                                      .lastWhere((d) => d.name == 'Default');
                                }
                              },
                              assessmentTypes: _appBloc.assessmentTypes,
                              assessed: _assessed,
                              detailAssessmentType: _detailAssessmentType),
                          Container(height: 20.0)
                        ],
                      ),
                      _assessed
                          ? Column(
                              children: <Widget>[
                                _createInfoLine(
                                    context: context,
                                    label: 'Đánh giá từ bạn',
                                    message: _assessment.description,
                                    icon: Icon(Icons.comment),
                                    isHorizonal: false),
                                Divider(),
                                _assessment.imageLinks != null
                                    ? Center(
                                        child: Wrap(
                                            children: _assessment.imageLinks
                                                .map((image) {
                                          return GestureDetector(
                                            child: Container(
                                                padding: EdgeInsets.all(2.0),
                                                child: Image.network(
                                                  image,
                                                  width: 75,
                                                  height: 75,
                                                )),
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Image.network(image);
                                                },
                                              );
                                            },
                                          );
                                        }).toList()),
                                      )
                                    : SizedBox(),
                                Center(
                                  child: Text(
                                    'Cảm ơn bạn đã gửi đánh giá.',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: TextFormField(
                                      controller: _textFieldFeedbackController,
                                      maxLength: 255,
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                        labelText: 'Đánh giá',
                                        helperText:
                                            'Hãy nhập đánh giá của bạn.',
                                        border: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.teal)),
                                      ),
                                      keyboardType: TextInputType.multiline,
                                    )),
                                FlatButton(
                                  onPressed: () async {
                                    setState(() {
                                      images = List<Asset>();
                                    });

                                    List<Asset> resultList;
                                    String error;

                                    try {
                                      resultList =
                                          await MultiImagePicker.pickImages(
                                        maxImages: 15,
                                      );
                                    } on PlatformException catch (e) {
                                      error = e.message;
                                    }
                                    if (!mounted) return;
                                    setState(() {
                                      images = resultList;
                                    });
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.image),
                                      Text("Add image")
                                    ],
                                  ),
                                ),
                                Wrap(
                                  children: images.map((asset) {
                                    return Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: AssetThumb(
                                          asset: asset, width: 75, height: 75),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                      _assessed
                          ? SizedBox()
                          : Column(
                              children: <Widget>[
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    _isBuyer
                                        ? Expanded(
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child: RaisedButton(
                                                  color: Colors.redAccent,
                                                  child: new Text(
                                                    "Trả hàng",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subhead
                                                        .copyWith(
                                                            color:
                                                                Colors.white),
                                                  ),
                                                  onPressed: () {
                                                    _handleSendFeedback(
                                                        context, true);
                                                    _orderBloc
                                                        .getReturnShippingFee(
                                                            _order);
                                                  }),
                                            ),
                                          )
                                        : SizedBox(),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: RaisedButton(
                                            color: Colors.green,
                                            child: new Text(
                                              "Gửi đánh giá",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subhead
                                                  .copyWith(
                                                      color: Colors.white),
                                            ),
                                            onPressed: () =>
                                                _handleSendFeedback(
                                                    context, false)),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )
                    ],
                  )
                : SizedBox()
          ],
        ));
  }

  Widget _buildReturnShipping(BuildContext context) {
    final lang = S.of(context);
    bool isActivePart = _order.statusObj.id >= OrderStatusEnum.RETURN_REQUESTED;
    bool isCompleted = _order.statusObj.id >= OrderStatusEnum.RETURN_DONE;
    ShipProviderService shipProviderService = ShipProviderService();
    for (int i = 0;
        i < _order.productObj.shipProviderObj.shipProviderService.length;
        i++) {
      if (_order.productObj.shipProviderObj.shipProviderService[i].id ==
          _order.shipProviderServiceId) {
        shipProviderService =
            _order.productObj.shipProviderObj.shipProviderService[i];
      }
    }
    Assessment _assessment = Assessment();
    if (_order.orderAssessments != null)
      for (int i = 0; i < _order.orderAssessments.length; i++) {
        if (_order.orderAssessments[i].userId == _order.buyerObj.id) {
          _detailAssessmentType =
              _order.orderAssessments[i].detailAssessmentType;
          _assessment = _order.orderAssessments[i];
          break;
        }
      }
    Widget shippingStatusWidget = _shippingStatus(context, isCompleted);

    return Container(
        decoration: _containerDecoration(borderColor: Colors.red),
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Material(
              color: Colors.transparent,
              child: InkWell(
                  child: _createSectionHeader(context,
                      icon: Icons.local_shipping,
                      title: 'Return Shipping',
                      subtitle:
                          formatDateTimeToString(_order.returnShippingDone),
                      user: _user),
                  onTap: () {}),
            ),
            Divider(),
            _isBuyer
                ? SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Đánh giá từ người mua",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          BbSegmentedControl(
                              selectedChanged: (AssessmentType assessmentType,
                                  DetailAssessmentType
                                      detailAssessmentType) async {},
                              assessmentTypes: _appBloc.assessmentTypes,
                              assessed: true,
                              detailAssessmentType: _detailAssessmentType),
                          _createInfoLine(
                              context: context,
                              label: 'Phản hồi từ người mua',
                              message: _assessment.description,
                              icon: Icon(Icons.comment),
                              isHorizonal: false),
                          Divider(),
                          Text(
                            "Hình ảnh",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Center(
                            child: _assessment.imageLinks != null
                                ? Wrap(
                                    children:
                                        _assessment.imageLinks.map((image) {
                                    return GestureDetector(
                                      child: Container(
                                          padding: EdgeInsets.all(2.0),
                                          child: Image.network(
                                            image,
                                            width: 75,
                                            height: 75,
                                          )),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Image.network(image);
                                          },
                                        );
                                      },
                                    );
                                  }).toList())
                                : SizedBox(),
                          )
                        ],
                      )
                    ],
                  ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                Widget>[
              Divider(),
              Text(
                "Shipment",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _createInfoLine(
                  context: context,
                  label: "Shipping From",
                  message: _order.shippingAddress.toString() ?? "",
                  icon: Icon(MdiIcons.home),
                  isHorizonal: false),
              Container(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _createIconText(Icon(Icons.person_pin), 'Ship Provider'),
                    Text(
                      _order.productObj.shipProviderObj.name ??
                          lang.message_not_set,
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _createIconText(
                        Icon(Icons.local_laundry_service), 'Ship Service'),
                    Text(
                      shipProviderService.description ?? lang.message_not_set,
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _createIconText(Icon(Icons.face), 'Shipping Fee'),
                    Text(
                      formatCurrency(_order.returnShippingFee),
                    )
                  ],
                ),
              ),
              Container(height: 15.0),
              Divider(),
            ]),
            _order.statusObj.id >= OrderStatusEnum.RETURN_CONFIRM
                ? Column(
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                              child: Container(
                            child: Text(
                              'Trạng thái ship hàng',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            padding: EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8.0)),
                            margin: EdgeInsets.all(10.0),
                          )),
                        ],
                      ),
                      shippingStatusWidget
                    ],
                  )
                : SizedBox()
          ],
        ));
  }

  _shippingStatus(BuildContext context, bool isCompleted) {
    List<Widget> shippingStatusWidget = [];
    ShippingStatusEnum shippingStatusEnum = ShippingStatusEnum();
    if (isCompleted) {
      for (int i = ShippingStatusEnum.PENDING;
          i <= ShippingStatusEnum.DELIVERED;
          i++) {
        shippingStatusWidget.add(Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: Card(
                elevation: 0,
                margin: EdgeInsets.all(0.0),
                child: Container(
                  width: double.infinity,
                  height: 70.0,
                  child: Text(shippingStatusEnum.shippingStatusName[i - 1]),
                ),
              ),
            ),
            i == ShippingStatusEnum.DELIVERED
                ? SizedBox()
                : Positioned(
                    top: 20.0,
                    bottom: 0.0,
                    left: 35.0,
                    child: Container(
                      height: double.infinity,
                      width: 1.0,
                      color: Colors.grey,
                    ),
                  ),
            Positioned(
              left: 25.0,
              child: Container(
                decoration:
                    BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                height: 20.0,
                width: 20.0,
              ),
            )
          ],
        ));
      }
      return Wrap(
        children: shippingStatusWidget,
      );
    } else {
      return StreamBuilder(
          stream: _appBloc.streamEvent,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData &&
                snapshot.data["type"] == NotificationTypeEnum.ORDER) {
              _order.shippingStatusId = snapshot.data["shipping_status_id"];
            }
            shippingStatusWidget = [];
            for (int i = ShippingStatusEnum.PENDING;
                i <= ShippingStatusEnum.DELIVERED;
                i++) {
              shippingStatusWidget.add(Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0),
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.all(0.0),
                      child: Container(
                        width: double.infinity,
                        height: 70.0,
                        child:
                            Text(shippingStatusEnum.shippingStatusName[i - 1]),
                      ),
                    ),
                  ),
                  i == ShippingStatusEnum.DELIVERED
                      ? SizedBox()
                      : Positioned(
                          top: 20.0,
                          bottom: 0.0,
                          left: 35.0,
                          child: Container(
                            height: double.infinity,
                            width: 1.0,
                            color: Colors.grey,
                          ),
                        ),
                  Positioned(
                    left: 25.0,
                    child: _order.shippingStatusId == i
                        ? ScaleTransition(
                            scale: animation,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.green, shape: BoxShape.circle),
                              height: 20.0,
                              width: 20.0,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                color: _order.shippingStatusId >= i
                                    ? Colors.green
                                    : Colors.grey,
                                shape: BoxShape.circle),
                            height: 20.0,
                            width: 20.0,
                          ),
                  )
                ],
              ));
            }
            return Wrap(
              children: shippingStatusWidget,
            );
          });
    }
  }

  Widget _buildChatChannelPart(BuildContext context) {
    return SimpleDialog(
      children: <Widget>[
        Container(
            decoration: _containerDecoration(),
            margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: StreamBuilder(
                stream: _messageBloc.streamMessage,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Message>> snapshot) {
                  if (snapshot.hasData) {
                    return ChatMessageListWidget(
                        title: "Chat channel",
                        messages: snapshot.data,
                        isPopup: false,
                        pagination: _pagination,
                        isEditable: _user != null,
                        addMessageCallback: (String message) {
                          if ((message ?? "").length > 0) {
                            var newMessage = new Message(
                                content: message,
                                senderObj: _user,
                                datetime: DateFormat("yyyy-MM-dd hh:mm:ss")
                                    .format(DateTime.now()));
                            _chatMessage.insert(0, newMessage);
                            _messageBloc.messageSink.add(_chatMessage);
                            _messageBloc.updateMessage({
                              "message": newMessage.toJson(),
                              "order_id": _order.id,
                              "access_token": _user.accessToken
                            });
                          }
                        },
                        loadMore: (int page) {
                          _page = page;
                          this.getOrderChat();
                        },
                        shouldUpdateCloudMessage:
                            (Message message, int notificationTypeEnum) {
                          if (notificationTypeEnum ==
                              NotificationTypeEnum.ORDER_CHAT) {
                            _chatMessage.insert(0, message);
                            if (this.mounted)
                              _messageBloc.messageSink.add(_chatMessage);
                          }
                        });
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Chat channel",
                          style: TextStyle(color: Colors.grey)),
                      Divider(),
                      Center(
                        child: CircularProgressIndicator(),
                      )
                    ],
                  );
                }))
      ],
    );
  }

  _handleSelectPaymentMethod(BuildContext context) async {
    var ret = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PaymentMethodListWidget(
          sellPrice: _order.sellPrice,
        );
      },
    );

    if (ret != null) {
      showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: Text('Thanh toán bằng tài khoản ${ret.name}'),
          actions: <Widget>[
            FlatButton(
              onPressed: () => {Navigator.of(context).pop()},
              child: Text('No'),
            ),
            FlatButton(
              onPressed: () async {
                setState(() {
                  _saving = true;
                  _order.paymentFee = ret.fee;
                  _order.paymentMethodObj = ret;
                  _orderBloc.calculateOrderFee(_order, null, false);
                  Navigator.of(context).pop();
                });
                bool result = false;

                bool createShippingOrder =
                    await _orderBloc.createShippingOrder(_order);
                if (createShippingOrder) {
                  if (ret.id == PaymentMethodEnum.BB_ACCOUNT) {
                    result = await _orderBloc.paymentBloc
                        .doPaymentWithBbAccount(_order);
                  } else if (ret.id == PaymentMethodEnum.VNPAY) {
                    result = await _orderBloc.paymentBloc
                        .doPaymentWithVNPay(context, _order);
                  }
                }

                if (result) {
                  _saving = false;
                  setState(() {
                    _order.statusObj.id = OrderStatusEnum.ORDER_PAID;
                    _user.currentPaymentMethodObj = ret;
                  });
                } else {
                  setState(() {
                    _saving = false;
                  });
                }
              },
              child: Text('Yes'),
            ),
          ],
        ),
      );
    }
  }

  _handleSendFeedback(BuildContext context, bool isReturnShip) async {
    if (_detailAssessmentType != null) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text('Xác nhận'),
            content: Text('Bạn đồng ý gửi nội dung đánh giá?'),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () async {
                  setState(() {
                    _saving = true;
                  });
                  Navigator.of(context).pop();
                  var response = await _uploadImage();
                  var imageLinks;
                  if (response != null) {
                    response = json.decode(response);
                    if (response['success']) {
                      imageLinks = List<String>.from(response['data']['link']);
                    }
                  }
                  var assessment = Assessment(
                    orderId: _order.id,
                    userId: _user.id,
                    detailAssessmentType: _detailAssessmentType,
                    description: _textFieldFeedbackController.text,
                    imageLinks: imageLinks,
                  );
                  int orderStatus = 0;
                  if (_isBuyer) {
                    orderStatus = isReturnShip
                        ? OrderStatusEnum.RETURN_CONFIRM
                        : OrderStatusEnum.TRANSACTION_FINISHED;
                  } else {
                    if (_order.statusObj.id >= OrderStatusEnum.RETURN_CONFIRM)
                      orderStatus = _order.statusObj.id;
                    else
                      orderStatus = OrderStatusEnum.ASSESSMENT;
                  }
                  Assessment retAssessment =
                      await _orderBloc.updateOrderAssessment(
                          assessment,
                          orderStatus,
                          _user.id == _order.buyerObj.id
                              ? _order.productObj.ownerObj.id
                              : _order.buyerObj.id,
                          _user.accessToken,
                          _order.returnShippingFee ?? 0);
                  if (retAssessment != null) {
                    _order.statusObj =
                        _appBloc.getStatusObjectById([orderStatus]);
                    setState(() {
                      _saving = false;
                      _order.orderAssessments.add(retAssessment);
                    });
                  }
                },
              ),
            ],
          );
        },
      );
    } else
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              "Vui lòng đánh giá cho ${_isBuyer ? 'người bán' : 'người mua'}")));
  }

  _uploadImage() async {
    if (images != null && images.length > 0) {
      //Assessment
      List<dynamic> listImg = List();
      for (int i = 0; i < images.length; i++) {
        ByteData byteData = await images[i].requestOriginal();
        if (byteData != null) listImg.add(byteData.buffer.asUint8List());
      }

      final _repository = Repository();
      if (listImg != null && listImg.length > 0) {
        var response = await _repository.apiProvider
            .uploadImages(listImg, _user.accessToken);
        return response;
      }
      return null;
    }
  }

  _handleApproveOrder(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text('Xác nhận'),
          content: Text('Bạn đồng ý cho đơn hàng này?'),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () async {
                var message;
                var retOrder = await _orderBloc.updateOrderStatus({
                  'id': _order.id,
                  'status_id': OrderStatusEnum.ORDER_APPROVED,
                  'notification_user_id': _order.buyerObj.id,
                  'access_token': _appBloc.loginUser.accessToken
                });
                if (retOrder != null && retOrder) {
                  setState(() {
                    _order.statusObj = _appBloc
                        .getStatusObjectById([OrderStatusEnum.ORDER_APPROVED]);
                  });
                  message = 'Cập nhật trạng thái đơn hàng thành công';
                } else {
                  message = 'Cập nhật trạng thái đơn hàng thất bại';
                }

                var flushbar = Flushbar(
                  title: 'Thông báo',
                  message: message,
                  duration: Duration(seconds: 3),
                  backgroundColor:
                      (retOrder != null) ? Colors.green : Colors.red,
                );
                await flushbar.show(context);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _handleRejectOrder(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text('Xác nhận'),
          content: Text('Bạn từ chối đơn hàng này?'),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () async {
                var message;
                var retOrder = await _orderBloc.updateOrderStatus({
                  'id': _order.id,
                  'status_id': OrderStatusEnum.ORDER_REJECTED,
                  'notification_user_id': _order.buyerObj.id,
                  'access_token': _appBloc.loginUser.accessToken
                });
                if (retOrder != null && retOrder) {
                  setState(() {
                    _order.statusObj = _appBloc
                        .getStatusObjectById([OrderStatusEnum.ORDER_REJECTED]);
                  });
                  message = 'Cập nhật trạng thái đơn hàng thành công';
                } else {
                  message = 'Cập nhật trạng thái đơn hàng thất bại';
                }

                var flushbar = Flushbar(
                  title: 'Thông báo',
                  message: message,
                  duration: Duration(seconds: 3),
                  backgroundColor:
                      (retOrder != null) ? Colors.green : Colors.red,
                );
                await flushbar.show(context);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget lineProgress(int orderStatus) {
    return Center(
        child: Container(
      color: _order.statusObj.id >= orderStatus ? Colors.green : Colors.red,
      height: 25,
      width: 2,
    ));
  }

  Widget _imageStack(String img) => ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: CachedNetworkImage(
            imageUrl: img,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => new Icon(Icons.error)),
      );

  Widget _drawTriangleShape(BuildContext context, Color color) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5.0),
            child: CustomPaint(
              painter: TrianglePainter(color: color),
              child: Container(
                height: 20,
              ),
            ),
          )
        ]);
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                icon != null
                    ? _createIconText(icon, label)
                    : Text(label,
                        style: labelStyle ??
                            CustomTextStyle.labelInformation(context)),
                Expanded(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(message,
                            style: messageStyle ??
                                Theme.of(context).textTheme.title)))
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
                        EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
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

  Widget _createSectionHeader(BuildContext context,
      {IconData icon, String title, String subtitle, User user}) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 32.0,
          ),
        ),
        Container(
            width: 1.0,
            height: 50.0,
            color: Colors.grey.shade100,
            margin: EdgeInsets.symmetric(horizontal: 8.0)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.title,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: CustomTextStyle.subLabelInformation(context),
            )
          ],
        ),
        Spacer(),
        _avatarStack(user),
      ],
    );
  }

  Widget _avatarStack(User user) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          var route = new MaterialPageRoute(
              builder: (BuildContext context) => ProfilePage(user: user));
          Navigator.of(context).push(route);
        },
        child: CircleAvatar(
            backgroundImage: user?.avatar != null
                ? NetworkImage(user.avatar)
                : AssetImage("assets/images/default_avatar.png"),
            radius: 20.0),
      ),
    );
  }

  Future getOrderChat() async {
    List res = await _messageBloc.getOrderChatMessage(_order.id, _page);
    if (res != null) {
      _chatMessage.addAll(res[0]);
      _pagination = res[1];
      if (this.mounted) _messageBloc.messageSink.add(_chatMessage);
    }
  }
}

class TrianglePainter extends CustomPainter {
  Color color;

  TrianglePainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // set the paint color to be white
    paint.color = Colors.white;
    // Create a rectangle with size and width same as the canvas
    var rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // draw the rectangle using the paint
    canvas.drawRect(rect, paint);
    paint.color = this.color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;

    var xCenter = size.width / 2;
    var radius = size.height;

    // create a path
    var path = Path();
    path.lineTo(size.width / 2 - size.height, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width / 2 + size.height, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
