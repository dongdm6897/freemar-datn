import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Product/actions/product_tabs.dart';
import 'package:flutter_rentaza/models/Sale/order.dart';
import 'package:flutter_rentaza/ui/pages/product/order_detail.dart';
import 'package:flutter_rentaza/ui/pages/product/product_detail.dart';
import 'package:flutter_rentaza/ui/pages/utils/help_screen.dart';
import 'package:flutter_rentaza/ui/widgets/product_gird.dart';
import 'package:flutter_rentaza/utils/custom_style.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';

class OrderFinishPage extends StatefulWidget {
  final Order order;

  OrderFinishPage({Key key, this.order}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _OrderFinishPageState();
  }
}

class _OrderFinishPageState extends State<OrderFinishPage> {
  AppBloc _appBloc;
  Order _order;

  @override
  void initState() {
    _appBloc = AppBloc();
    _order = widget.order;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushNamedAndRemoveUntil(
            UIData.HOMEPAGE, (Route<dynamic> route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: Builder(
            builder: (context) => new SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      _buildBasicInfoPart(context),
                      _buildInformPart(context),
                      _buildCommandPart(context),
//                    _buildRelatedProductsPart(context)
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
        lang.order_finish,
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
          decoration: _containerDecoration(),
          padding: EdgeInsets.all(12.0),
          child: new Row(
            children: <Widget>[
              Container(
                width: 80.0,
                child: _imageStack(_order.productObj.representImage),
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
                                _order.productObj.name,
                                style: new TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _order.productObj.brandObj?.name ?? "",
                                style: new TextStyle(
                                    fontSize: 16.0, color: Colors.grey),
                              ),
                              Text(
                                _order.productObj.price.toString(),
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
          )),
      onTap: () {
        var route = MaterialPageRoute(
            builder: (BuildContext context) =>
                ProductDetailPage(product: _order.productObj));
        Navigator.of(context).push(route);
      },
    );
  }

  Widget _buildRelatedProductsPart(BuildContext context) {
    final lang = S.of(context);

    return Container(
        decoration: _containerDecoration(),
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              lang.product_related,
              style: TextStyle(color: Colors.grey),
            ),
            ProductGird(
              productTabs: ProductTabs(
                  tabId: _order.productObj.id, name: 'related_products'),
            )
          ],
        ));
  }

  Widget _buildInformPart(BuildContext context) {
    final lang = S.of(context);

    return new Container(
        decoration: _containerDecoration(),
        padding: EdgeInsets.all(12.0),
        margin: EdgeInsets.only(top: 8.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Ban da dat hang thanh cong!",
                style: CustomTextStyle.textTitleEmphasize(context),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "Mo tab products de theo doi don hang cua ban.",
                  style: CustomTextStyle.textExplainNormal(context),
                )),
            Image.asset('assets/images/order_flow.png', fit: BoxFit.cover)
          ],
        ));
  }

  Widget _buildCommandPart(BuildContext context) {
    final lang = S.of(context);

    return new Container(
        decoration: _containerDecoration(),
        padding: EdgeInsets.all(12.0),
        margin: EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            OutlineButton(
              borderSide: BorderSide(color: Colors.green),
              child: new Text(
                lang.title_home,
              ),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    UIData.HOMEPAGE, (Route<dynamic> route) => false);
              },
            ),
            OutlineButton(
              borderSide: BorderSide(color: Colors.red),
              child: new Text(
                lang.product_products_in_order,
              ),
              onPressed: () {
                var route = MaterialPageRoute(
                    builder: (BuildContext context) =>
                        OrderDetailPage(order: _order));
                Navigator.of(context).push(route);
              },
            )
          ],
        ));
  }

  Widget _imageStack(String img) => CachedNetworkImage(
      imageUrl: img,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          Center(child: new CircularProgressIndicator()),
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
}
