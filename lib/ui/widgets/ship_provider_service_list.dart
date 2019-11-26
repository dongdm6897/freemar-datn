import 'package:flutter/material.dart';
import 'package:flutter_rentaza/generated/i18n.dart';

class ShipProviderServiceListWidget extends StatelessWidget {
  final listShipProviderService;

  ShipProviderServiceListWidget(this.listShipProviderService);

  @override
  Widget build(BuildContext context) {
    var lang = S.of(context);
    var size = MediaQuery.of(context).size;

    return SimpleDialog(
        contentPadding: EdgeInsets.all(10.0),
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Flexible(
                  child: Column(
                children: <Widget>[
                  Text(
                    "Ship Provider Service",
                    style: new TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    width: size.width * 0.9,
                    height: listShipProviderService.length * 60.0,
                    child: ListView.builder(
                        itemCount: listShipProviderService.length,
                        itemBuilder: (BuildContext context, int idx) {
                          var item = listShipProviderService[idx];
                          return ListTile(
                            contentPadding: EdgeInsets.all(0.0),
                            title: Column(
                              children: <Widget>[
                                Row(children: <Widget>[
                                  Padding(padding: EdgeInsets.all(5.0)),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(item.description),
                                      Text(
                                        item.serviceName ?? "",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 9.0),
                                      ),
                                    ],
                                  )
                                ]),
                                Divider()
                              ],
                            ),
                            trailing: Icon(Icons.arrow_right),
                            onTap: () async {
                              Navigator.pop(context, item);
                            },
                          );
                        }),
                  ),
                ],
              ))
            ],
          )
        ]);
  }
}
