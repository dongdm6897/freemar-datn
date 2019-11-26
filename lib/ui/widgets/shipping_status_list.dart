import 'package:flutter/material.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Sale/order.dart';
import 'package:flutter_rentaza/models/Sale/shipping_status.dart';
import 'package:flutter_rentaza/utils/custom_style.dart';

class ShippingStatusListWidget extends StatefulWidget {
  final Order order;

  ShippingStatusListWidget({@required this.order});

  @override
  _ShippingStatusListWidget createState() => _ShippingStatusListWidget();
}

class _ShippingStatusListWidget extends State<ShippingStatusListWidget> {
  Order _order;
  List<ShippingStatus> _shippingStatuses;

  @override
  void initState() {
    _order = widget.order;

    _shippingStatuses = new List<ShippingStatus>();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(ShippingStatusListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var lang = S.of(context);

    return SimpleDialog(contentPadding: EdgeInsets.all(10.0), children: <
        Widget>[
      new Row(
        children: <Widget>[
          new Flexible(
              child: Column(
            children: <Widget>[
              Text(
                "Follow shipping status",
                style: new TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Divider(),
              Container(
                  width: 450,
                  height: _shippingStatuses.length * 80.0,
                  constraints: BoxConstraints(minHeight: 100, maxHeight: 500),
                  child: _shippingStatuses.length > 0
                      ? ListView.builder(
                          itemCount: _shippingStatuses.length,
                          itemBuilder: (BuildContext content, int index) {
                            ShippingStatus item = _shippingStatuses[index];
                            return ListTile(
                              title: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(item.name,
                                      style: CustomTextStyle.textExplainNormal(
                                          context)),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                          child: Container(
                                        child: Text(
                                          item.name,
                                          style: TextStyle(
                                              color: Colors.grey.shade700),
                                        ),
                                        padding: EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                        margin: EdgeInsets.only(
                                            left: 5.0, top: 5.0, bottom: 5.0),
                                      )),
                                    ],
                                  ),
//                                  Align(
//                                    alignment: Alignment.centerRight,
//                                    child: Text(item.datetime,
//                                        style: CustomTextStyle
//                                            .textSubtitleDatetime(context)),
//                                  ),
                                  Divider()
                                ],
                              ),
                              trailing: (_order.shippingStatusId == item.id)
                                  ? Icon(Icons.check)
                                  : null,
                              onTap: () async {
                                Navigator.pop(context, item);
                              },
                            );
                          })
                      : null),
              Divider(),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: RaisedButton.icon(
                      color: Colors.white,
                      onPressed: () {},
                      icon: Icon(Icons.refresh),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(5.0)),
                      label: Text("Get latest status")))
            ],
          ))
        ],
      )
    ]);
  }
}
