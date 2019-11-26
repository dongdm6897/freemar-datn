import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/User/user.dart';

class ShipProviderListWidget extends StatefulWidget {
  @override
  _ShipProviderListWidget createState() => _ShipProviderListWidget();
}

class _ShipProviderListWidget extends State<ShipProviderListWidget> {
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
  void didUpdateWidget(ShipProviderListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      lang.product_ship_provider,
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    width: size.width * 0.9,
                    height: _appBloc.shipProviders.length * 70.0,
                    child: ListView.builder(
                        itemCount: _appBloc.shipProviders.length,
                        itemBuilder: (BuildContext context, int idx) {
                          var item = _appBloc.shipProviders[idx];
                          return ListTile(
                            contentPadding: EdgeInsets.all(0.0),
                            title: Column(
                              children: <Widget>[
                                Row(children: <Widget>[
                                  CircleAvatar(
                                      child: Image.network(
                                    item.logo,
                                    height: 100.0,
                                    width: 100.0,
                                  )), //item.logo
                                  Padding(padding: EdgeInsets.all(5.0)),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(item.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                        item.description ?? "Đơn vị vận chuyển",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  )
                                ]),
                                Divider()
                              ],
                            ),
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
