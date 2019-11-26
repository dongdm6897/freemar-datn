import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/setting_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingBloc settingBloc;
  int column = 2;

  @override
  initState() {
    super.initState();
    settingBloc = SettingBloc();
    settingBloc.getProductColumn().then((value) {
      if (value != null && value > 0) {
        setState(() {
          column = value;
        });
      }
    });
  }

  @override
  dispose() {
    super.dispose();
  }

  Widget bodyData(BuildContext context) => SingleChildScrollView(
          child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
            AppBloc().loginUser != null
                ? ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, bottom: 5.0),
                        child: Text(
                          "THIẾT LẬP TÀI KHOẢN",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      Container(
                        decoration:
                            BoxDecoration(color: Colors.white, boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20.0,
                          ),
                        ]),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text("Profile"),
                              leading: Icon(MdiIcons.faceProfile),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, UIData.EDIT_PROFILE);
                              },
                              trailing: Icon(Icons.keyboard_arrow_right),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(top: 25.0, bottom: 5.0),
              child: Text(
                "CÀI ĐẶT ỨNG DỤNG",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20.0,
                ),
              ]),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text(S.of(context).notifications),
                    onTap: () {
                      Navigator.pushNamed(context, UIData.SET_UP_NOTIFICATIONS);
                    },
                    trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(MdiIcons.formatColumns),
                    title: Text("Column"),
                    trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                            value: column,
                            items: [
                              DropdownMenuItem<int>(
                                  value: 2,
                                  child: Text(
                                    "2",
                                  )),
                              DropdownMenuItem<int>(
                                  value: 3,
                                  child: Text(
                                    "3",
                                  )),
                            ],
                            onChanged: (value) async {
                              var res =
                                  await settingBloc.saveProductColumn(value);
                              if (res != null && res) {
                                Navigator.of(context)
                                    .pushNamed(UIData.HOMEPAGE);
                              }
                            })),
                  ),
                ],
              ),
            ),
          ]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: bodyData(context)),
    );
  }
}
