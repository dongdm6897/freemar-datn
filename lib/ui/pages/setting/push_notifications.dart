import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/user_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SetPushNotificationPage extends StatefulWidget {
  @override
  State createState() => _SetPushNotificationPage();
}

class _SetPushNotificationPage extends State<SetPushNotificationPage> {
  User _user = AppBloc().loginUser;
  UserBloc _userBloc;
  bool _saving = false;

  @override
  void initState() {
    _userBloc = UserBloc();
    super.initState();
  }

  @override
  void dispose() {
    _userBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Push Notifications"),
        ),
        body: Builder(
            builder: (context) => SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 25.0, bottom: 5.0, left: 10.0),
                        child: Text(
                          S.of(context).notifications,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize:
                                  Theme.of(context).textTheme.title.fontSize),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 25.0),
                          decoration:
                              BoxDecoration(color: Colors.white, boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 20.0,
                            ),
                          ]),
                          child: _user != null
                              ? Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(Icons.comment),
                                      title:
                                          Text(S.of(context).product_commented),
                                      trailing: Checkbox(
                                        value: _user.notifyProductComment,
                                        onChanged: (bool value) {
                                          setState(() {
                                            _user.notifyProductComment = value;
                                          });
                                        },
                                      ),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.chat_bubble),
                                      title: Text("Order chat"),
                                      trailing: Checkbox(
                                        value: _user.notifyOrderChat,
                                        onChanged: (bool value) {
                                          setState(() {
                                            _user.notifyOrderChat = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox())
                    ],
                  ),
                )),
        bottomNavigationBar: BottomAppBar(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new FlatButton(
                child: new Text(S.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text(S.of(context).save),
                onPressed: () async {
                  setState(() {
                    _saving = true;
                  });
                  bool res = false;
                  if (_user != null)
                    res = await _userBloc.notificationSettings({
                      "id": _user.id,
                      "notify_product_comment": _user.notifyProductComment,
                      "notify_order_chat": _user.notifyOrderChat,
                      "access_token": _user.accessToken
                    });
                  else
                    res = true;
                  if (res)
                    Navigator.of(context).pop();
                  else
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Đã xảy ra lỗi,xin vui lòng thử lại.")));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
