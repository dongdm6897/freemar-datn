import 'package:flutter/material.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/ui/pages/user/login.dart';

Future<void> requiredLogin(BuildContext context) {
  var lang = S.of(context);
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text(lang.please_login_to_continue + " !!"),
        actions: <Widget>[
          FlatButton(
            child: Text(lang.cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: new Text(lang.register_login),
            onPressed: () {
              Navigator.of(context).pop(requiredLogin);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      );
    },
  );
}
