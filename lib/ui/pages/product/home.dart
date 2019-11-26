import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/notification_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/ui/pages/notification/notification_page.dart';
import 'package:flutter_rentaza/ui/pages/product/search/search.dart';
import 'package:flutter_rentaza/ui/pages/product/shopping.dart';
import 'package:flutter_rentaza/ui/widgets/collection_list.dart';
import 'package:flutter_rentaza/ui/widgets/common_drawer.dart';
import 'package:flutter_rentaza/ui/widgets/custom_float.dart';
import 'package:flutter_rentaza/ui/widgets/follow_user_list.dart';
import 'package:flutter_rentaza/ui/widgets/required_login.dart';
import 'package:flutter_rentaza/utils/navigation_service.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  int _currentIndex = 0;
  User _user;
  List<Widget> _screens;
  NotificationBloc _notificationBloc;

  @override
  void initState() {
    _user = AppBloc().loginUser;
    _notificationBloc = NotificationBloc();
    _notificationBloc.getUnreadCount(_user?.id);

    _screens = [
      ShoppingPage(),
      Scaffold(
          drawer: CommonDrawer(user: _user),
          appBar: AppBar(title: Text(S.current.follow_user_list)),
          body: FollowUserList(getAllSeller: false),
          floatingActionButton: CustomFloat(
            icon: Icons.camera_alt,
            qrCallback: () {
              if (_user == null)
                requiredLogin(context);
              else
                Navigator.pushNamed(context, UIData.CREATE_PRODUCT);
            },
          )),
      Search(),
      Scaffold(
          drawer: CommonDrawer(user: _user),
          appBar: AppBar(title: Text(S.current.collection)),
          body: CollectionListWidget(),
          floatingActionButton: CustomFloat(
            icon: Icons.camera_alt,
            qrCallback: () {
              if (_user == null)
                requiredLogin(context);
              else
                Navigator.pushNamed(context, UIData.CREATE_PRODUCT);
            },
          )),
      NotificationPage()
    ];

    super.initState();
  }

  @override
  void dispose() {
    _notificationBloc.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => exit(0),
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: StreamBuilder(
            initialData: {
              'type': NotificationTypeEnum.SHOW_HIDE_BOTTOM_BAR,
              'hide': false
            },
            stream: AppBloc().streamEvent,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData &&
                  snapshot.data['type'] ==
                      NotificationTypeEnum.SHOW_HIDE_BOTTOM_BAR &&
                  snapshot.data['hide'] == true) {
                return SizedBox(height: 0);
              }
              return BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.redAccent,
                backgroundColor: Colors.white,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  if (index == 2) if (_notificationBloc.unread > 0)
                    _notificationBloc
                        .setUnread(AppBloc().loginUser?.accessToken);
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    title: Text('Home'),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people),
                    title: Text('Follows'),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    title: Text('Search'),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.collections),
                    title: Text('Collections'),
                  ),
                  BottomNavigationBarItem(
                    icon: IconTheme(
                        data: IconThemeData(
                            color: _currentIndex == 4
                                ? Colors.redAccent
                                : Colors.grey),
                        child: Stack(
                          children: <Widget>[
                            Icon(
                              Icons.notifications,
                            ),
                            Positioned(
                                top: 0,
                                right: 0,
                                child: StreamBuilder(
                                    stream: _notificationBloc.streamUnreadCount,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<int> unread) {
                                      if (unread.hasData && unread.data > 0)
                                        return Container(
                                          padding: const EdgeInsets.all(2.0),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.redAccent,
                                          ),
                                          child: Text(unread.data.toString(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10.0)),
                                        );
                                      return SizedBox();
                                    }))
                          ],
                        )),
                    title: Text('Notifications'),
                  ),
                ],
                currentIndex: _currentIndex,
              );
            }),
      ),
    );
  }
}
