import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/models/User/user.dart';

class MoneyAccountSelector extends StatefulWidget {
  @override
  _MoneyAccountSelectorState createState() => _MoneyAccountSelectorState();
}

class _MoneyAccountSelectorState extends State<MoneyAccountSelector> {
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
  Widget build(BuildContext context) {
    return SimpleDialog(children: <Widget>[
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
        Text(
          "Tài khoản đã sử dụng",
          style: new TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
      ]),
      Container(
          height: 500.0,
          width: 400.0,
          padding: EdgeInsets.all(10.0),
          margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
          child: ListView.builder(
              itemCount: _user.moneyAccounts?.length??0,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    _user.moneyAccounts[index].name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_user.moneyAccounts[index].number),
                  onTap: (){
                    Navigator.of(context).pop(_user.moneyAccounts[index]);
                  },
                );
              }))
    ]);
  }
}
