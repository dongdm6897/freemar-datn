import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/message_bloc.dart';
import 'package:flutter_rentaza/blocs/setting_bloc.dart';
import 'package:flutter_rentaza/blocs/user_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Product/actions/product_tabs.dart';
import 'package:flutter_rentaza/models/Product/attribute.dart';
import 'package:flutter_rentaza/models/Product/message.dart';
import 'package:flutter_rentaza/models/Product/product.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/ui/pages/product/order_product.dart';
import 'package:flutter_rentaza/ui/pages/utils/help_screen.dart';
import 'package:flutter_rentaza/ui/widgets/attribute_widget.dart';
import 'package:flutter_rentaza/ui/widgets/chat_message_list.dart';
import 'package:flutter_rentaza/ui/widgets/gallery_photoview.dart';
import 'package:flutter_rentaza/ui/widgets/product_gird.dart';
import 'package:flutter_rentaza/ui/widgets/required_login.dart';
import 'package:flutter_rentaza/ui/widgets/user_info.dart';
import 'package:flutter_rentaza/utils/custom_style.dart';
import 'package:flutter_rentaza/utils/string_utils.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';
import 'package:intl/intl.dart';
import 'package:simple_logger/simple_logger.dart';

const kExpandedHeight = 400.0;

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final bool isJumpToComment;

  ProductDetailPage({Key key, this.product, this.isJumpToComment = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _ProductDetailPageState();
  }
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final SimpleLogger _logger = SimpleLogger()..mode = LoggerMode.print;
  final _comments = <Message>[];
  GlobalKey _keyComment = GlobalKey();
  Product _product;
  User _user;
  AppBloc _appBloc;
  UserBloc _userBloc;
  MessageBloc _messageBloc;
  ScrollController _scrollController;
  List<Product> _watchedProducts;
  Map _pagination;
  int _page = 1;

  final _currentImageIndex = new ValueNotifier(0);
  final _showTitle = new ValueNotifier(false);
  Offset positionWidgetComment = Offset(0, 0);

  SettingBloc _settingBloc;

  @override
  void initState() {
    super.initState();

    _logger.info("initState STARTED...");

    _appBloc = AppBloc();
    _userBloc = new UserBloc();
    _settingBloc = SettingBloc();
    _messageBloc = MessageBloc();
    _product = widget.product;
    _user = _appBloc.loginUser;

    // Update to watched product list
    if (_user != null) if (_product.isPublic)
      _userBloc.setWatched(_user, _product);
    _watchedProducts = _user?.watchedProducts;

    _scrollController = ScrollController()..addListener(showTitle);

    this.getProductComment();

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        final RenderBox renderBox =
            _keyComment.currentContext.findRenderObject();
        positionWidgetComment = renderBox.localToGlobal(Offset.zero);
        if (widget.isJumpToComment)
          _scrollController.jumpTo(positionWidgetComment.dy);
      });
    }
  }

  Future getProductComment() async {
    List res = await _messageBloc.getProductCommentMessage(_product.id, _page);
    if (res != null) {
      _comments.addAll(res[0]);
      _pagination = res[1];
      if (this.mounted) _messageBloc.messageSink.add(_comments);
    }
  }

  @override
  void dispose() {
    _userBloc.dispose();
    _messageBloc.dispose();
    super.dispose();
  }

  void showTitle() {
    bool showTitle = _scrollController.hasClients &&
        _scrollController.offset > kExpandedHeight - kToolbarHeight;
    _showTitle.value = showTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(controller: _scrollController, slivers: <Widget>[
        _buildSliverAppBar(context),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Column(
                children: <Widget>[
                  _buildBasicInfoPart(context),
                  _buildDetailInfoPart(context),
                  _buildSafeGuidePart(context),
                  Container(
                    decoration: _containerDecoration(),
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.only(top: 8.0),
                    child: UserInfoWidget(
                        user: _product.ownerObj,
                        isSideMode: false,
                        isSimpleMode: true,
                        title: "Seller informations",
                        isOnTapEnabled: true),
                  ),
                  _buildCommentPart(context),
                  _buildRelatedProductsPart(context),
                ]..removeWhere((w) => w == null),
              );
            },
            childCount: 1,
            addAutomaticKeepAlives: false,
          ),
        ),
      ]),
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final lang = S.of(context);

    _product.referenceImageLinks ??= [_product.representImage];

    return ValueListenableBuilder(
        valueListenable: _showTitle,
        builder: (context, value, _) {
          return SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            expandedHeight: kExpandedHeight,
            automaticallyImplyLeading: value,
            title: value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _product.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: CustomTextStyle.textTitleNormal(context),
                            ),
                            Text(
                              formatCurrency(_product.price,
                                  useNatureExpression: true),
                              style: CustomTextStyle.textPrice(context),
                            ),
                          ],
                        ),
                      ),
                      // IconButton(
                      //   onPressed: () =>
                      //       Share.share('https://freemar.com/profile'),
                      //   icon: Icon(Icons.share),
                      // ),
                      PopupMenuButton<int>(
                        onSelected: (int idx) {
                          switch (idx) {
                            case 0:
                            case 1:
                            case 2:
                              // Goto home screen
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  UIData.HOMEPAGE,
                                  (Route<dynamic> route) => false);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem<int>(
                                value: 0,
                                child: _createIconText(Icon(Icons.report),
                                    lang.product_report_bad_product)),
                            PopupMenuItem<int>(
                                value: 1,
                                child: _createIconText(
                                    Icon(Icons.share), lang.product_share)),
                            PopupMenuItem<int>(
                                value: 2,
                                child: _createIconText(
                                    Icon(Icons.home), lang.title_home))
                          ];
                        },
                      )
                    ],
                  )
                : IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
            flexibleSpace: value
                ? null
                : FlexibleSpaceBar(background: _buildImageCarouseSlider()),
          );
        });
  }

  Widget _buildImageCarouseSlider() {
    List<T> map<T>(List list, Function handler) {
      List<T> result = [];
      for (var i = 0; i < list.length; i++) {
        result.add(handler(i, list[i]));
      }
      return result;
    }

    List<GalleryItem> galleryItems = _product.referenceImageLinks
        .map((l) => GalleryItem(id: l, resource: l))
        .toList();

    Widget slider = Stack(children: [
      CarouselSlider(
        items: map<Widget>(
          _product.referenceImageLinks,
          (index, i) {
            return Stack(
              children: <Widget>[
                GestureDetector(
                    child: Container(
                        width: double.infinity, child: _imageStack(i)),
                    onDoubleTap: () {
                      // Open photo gallery view
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GalleryPhotoViewWrapper(
                              galleryItems: galleryItems,
                              backgroundDecoration: const BoxDecoration(
                                color: Colors.black,
                              ),
                              initialIndex: index,
                            ),
                          ));
                    }),
              ],
            );
          },
        ).toList(),
        height: 400.0,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 2),
        pauseAutoPlayOnTouch: Duration(seconds: 10),
        onPageChanged: (index) {
          _currentImageIndex.value = index;
        },
      ),
      ValueListenableBuilder(
          valueListenable: _currentImageIndex,
          builder: (context, value, _) {
            return Positioned(
                top: 350.0,
                left: 0.0,
                right: 0.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      map<Widget>(_product.referenceImageLinks, (index, url) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: value == index
                              ? Color.fromRGBO(0, 0, 0, 0.9)
                              : Color.fromRGBO(0, 0, 0, 0.2)),
                    );
                  }),
                ));
          })
    ]);

    return (_product.isOrdering || _product.isSoldOut)
        ? Banner(
            message: "SOLD OUT",
            location: BannerLocation.topStart,
            color: Colors.red,
            child: slider,
          )
        : slider;
  }

  Widget _buildBasicInfoPart(BuildContext context) {
    final lang = S.of(context);

    // Search some features
    var featureWidgetList = List<Widget>();

    // Add shipping free mark
    if (_product.shippingPaymentMethodObj != null) {
      featureWidgetList.add(new Container(
          padding: EdgeInsets.only(left: 5.0, right: 5.0),
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(4.0))),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.local_shipping,
                color: Colors.white,
                size: 20.0,
              ),
              Container(
                width: 5.0,
              ),
              Text(
                _product.shippingPaymentMethodObj.name,
                style: TextStyle(fontSize: 8.0, color: Colors.white),
              ),
            ],
          )));
    }

    return Container(
      decoration: _containerDecoration(),
      padding: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          featureWidgetList.length > 0
              ? Row(children: featureWidgetList)
              : const SizedBox(),
          SizedBox(height: featureWidgetList.length > 0 ? 5 : 0),
          new Row(
            mainAxisSize: MainAxisSize.max,
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
                    style: new TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                  Text(
                    formatCurrency(_product.price, useNatureExpression: true),
                    style: new TextStyle(
                        fontSize: 20.0,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.timer, size: 16.0, color: Colors.grey),
                      Text(formatTime(_product.createdAt),
                          style: CustomTextStyle.textTime(context))
                    ],
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDetailInfoPart(BuildContext context) {
    final lang = S.of(context);
    final iconSize = 20.0;

    return Container(
      decoration: _containerDecoration(),
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.only(top: 8.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            lang.product_informations,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Text(
              _product.description ?? "",
              style: TextStyle(color: Colors.black),
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: AttributeWidget(
                Attribute(
                    name: lang.product_category,
                    value: _product.categoryObj?.toString() ?? "",
                    iconName: 'category'),
                isEditMode: false,
                isShowIcon: true,
                isRequired: true),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: AttributeWidget(
                Attribute(
                    name: lang.product_brand,
                    value: _product.brandObj?.name ?? "",
                    iconName: 'business'),
                isEditMode: false,
                isShowIcon: true),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: AttributeWidget(
                Attribute(
                    name: lang.product_status,
                    value: _appBloc.productStatuses
                            .firstWhere((e) => e.id == _product.statusId,
                                orElse: () => null)
                            ?.name ??
                        "",
                    iconName: 'star'),
                isEditMode: false,
                isShowIcon: true),
          ),
          ..._product.attributeObjs?.map((a) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child:
                      AttributeWidget(a, isEditMode: false, isShowIcon: true),
                );
              }) ??
              [],
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: AttributeWidget(
                Attribute(
                    name: 'Ship time estimation',
                    value: _appBloc.shipTimeEstimation
                            .firstWhere(
                                (e) => e.id == _product.shipTimeEstimationId,
                                orElse: () => null)
                            ?.name ??
                        "",
                    iconName: 'local_shipping'),
                isEditMode: false,
                isShowIcon: true),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: AttributeWidget(
                Attribute(
                    name: 'Ship from',
                    value: _product.shippingFrom != null
                        ? _product.shippingFrom.province.name
                        : "",
                    iconName: 'place'),
                isEditMode: false,
                isShowIcon: true),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeGuidePart(BuildContext context) {
    final lang = S.of(context);

    return Container(
        decoration: _containerDecoration(),
        margin: EdgeInsets.only(top: 8.0),
        child: new ListTile(
          contentPadding: EdgeInsets.all(10.0),
          leading: SizedBox(
              height: 50,
              width: 50,
              child: Center(
                child: Icon(Icons.favorite,
                    color: Theme.of(context).accentColor, size: 40.0),
              )),
          title: Text('An toàn & uy tín là trên hết'),
          subtitle: Text(
              'Baibai đứng ra giữ tiền & chỉ giao tiền khi bên mua xác nhận giao dịch uy tín. Chi tiết tìm hiểu thêm...'),
          onTap: () {
            var route = MaterialPageRoute(
                builder: (BuildContext context) => new HelpScreen(
                    title: 'HELP: How to order product on BaiBai',
                    url: _appBloc.links["help3"]));
            Navigator.of(context).push(route);
          },
        ));
  }

  Widget _buildCommentPart(BuildContext context) {
    final lang = S.of(context);
    return Container(
        key: _keyComment,
        decoration: _containerDecoration(),
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(top: 8.0),
        child: StreamBuilder(
            stream: _messageBloc.streamMessage,
            builder:
                (BuildContext context, AsyncSnapshot<List<Message>> snapshot) {
              if (snapshot.hasData) {
                return ChatMessageListWidget(
                    title: lang.product_commented,
                    messages: snapshot.data,
                    isPopup: false,
                    pagination: _pagination,
                    isEditable: (_user != null && _product.isPublic),
                    addMessageCallback: (String message) {
                      if ((message ?? "").length > 0) {
                        var newMessage = new Message(
                            content: message,
                            senderObj: _user,
                            datetime: DateFormat("yyyy-MM-dd hh:mm:ss")
                                .format(DateTime.now()));
                        _comments.insert(0, newMessage);
                        _messageBloc.messageSink.add(_comments);
//                        _product.numberOfComments++;
                        _messageBloc.updateMessage({
                          "message": newMessage.toJson(),
                          "product_id": _product.id,
                          "access_token": _user.accessToken
                        });
                      }
                    },
                    loadMore: (int page) {
                      _page = page;
                      this.getProductComment();
                    },
                    shouldUpdateCloudMessage:
                        (Message message, int notificationTypeEnum) {
                      if (notificationTypeEnum ==
                          NotificationTypeEnum.PRODUCT_COMMENT) {
                        _comments.insert(0, message);
                        if (this.mounted)
                          _messageBloc.messageSink.add(_comments);
                      }
                    });
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(lang.product_commented,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Divider(),
                  Center(
                    child: CircularProgressIndicator(),
                  )
                ],
              );
            }));
  }

  Widget _buildRelatedProductsPart(BuildContext context) {
    final lang = S.of(context);

    return Container(
        decoration: _containerDecoration(),
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(top: 8.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              lang.product_related,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Divider(),
            FutureBuilder(
                future: _settingBloc.getProductColumn(),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.hasData)
                    return ProductGird(
                      physics: NeverScrollableScrollPhysics(),
                      productTabs: ProductTabs(
                          tabId: _product.id,
                          pageSize: snapshot.data ?? 2,
                          name: ProductTabs.ACTION_RELATED),
                    );
                  return SizedBox();
                })
          ],
        ));
  }

  Widget _buildBottomAppBar(BuildContext context) {
    var lang = S.of(context);
    var isFavorited =
        (_user != null) ? _user.checkFavorite(_product.id) : false;
    var isBuyableProduct = (!_product.isSoldOut) &&
        (!_product.isOrdering) &&
        (_product.ownerObj?.id != _user?.id);

    return BottomAppBar(
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: _product.isPublic
                      ? () {
                          if (this.mounted) {
                            if (_user != null) {
                              setState(() {
                                if (!isFavorited) {
                                  _userBloc.setFavorite(_user, _product);
                                } else {
                                  _userBloc.clearFavorite(_user, _product);
                                }
                              });
                            } else {
                              requiredLogin(context);
                            }
                          }
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                            isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                              _product.numberOfFavorites?.toString() ?? "0",
                              style: TextStyle(color: Colors.grey)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    _scrollController.jumpTo(positionWidgetComment.dy);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.comment, color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                              _product.numberOfComments?.toString() ?? "0",
                              style: TextStyle(color: Colors.grey)),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          isBuyableProduct
              ? Padding(
                  padding: EdgeInsets.all(5.0),
                  child: new FlatButton(
                    color: Theme.of(context).accentColor,
                    child: new Text(
                      lang.product_buy,
                      style: Theme.of(context)
                          .textTheme
                          .subhead
                          .copyWith(color: Colors.white),
                    ),
                    onPressed: () {
                      if (_user != null) {
                        if (_product.shippingFrom != null) {
                          var route = MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  OrderProductPage(product: _product));
                          Navigator.of(context).push(route);
                        } else
                          Flushbar(
                            title: "Product",
                            message: "ShippingFrom is null",
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.red,
                          ).show(context);
                      } else {
                        requiredLogin(context);
                      }
                    },
                  ))
              : SizedBox(),
        ],
      ),
    );
  }

  Widget _imageStack(String img) => CachedNetworkImage(
      imageUrl: img,
      height: 400,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(
            child: CircularProgressIndicator(),
          ),
      errorWidget: (context, url, error) => new Icon(Icons.error));

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

  Widget _createIconText(Icon icon, String text, {TextStyle labelStyle}) {
    return Row(children: <Widget>[
      icon,
      Padding(padding: EdgeInsets.all(5.0)),
      Text(text, style: labelStyle ?? CustomTextStyle.labelInformation(context))
    ]);
  }
}
