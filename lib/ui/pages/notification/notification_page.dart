import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/notification_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Notification/freemar_notification.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/ui/pages/notification/notification_page_detail.dart';
import 'package:flutter_rentaza/ui/pages/product/sell_manager.dart';
import 'package:flutter_rentaza/ui/widgets/common_drawer.dart';
import 'package:flutter_rentaza/ui/widgets/custom_float.dart';
import 'package:flutter_rentaza/ui/widgets/required_login.dart';
import 'package:flutter_rentaza/utils/colorful_app.dart';
import 'package:flutter_rentaza/utils/navigation_service.dart';
import 'package:flutter_rentaza/utils/no_data.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NotificationPage();
  }
}

class _NotificationPage extends State<NotificationPage> {
  NotificationBloc notificationBloc;
  User user;
  List<Widget> listTabBar = [];
  List<Widget> listTabBarView = [];
  final width =
      MediaQuery.of(NavigationService.navKey.currentContext).size.width;

  @override
  void initState() {
    super.initState();
    user = AppBloc().loginUser;
    notificationBloc = NotificationBloc();
    //Construction tab
    listTabBar.addAll([
      user != null
          ? Container(
              width: width / 2,
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text("Your", textAlign: TextAlign.center),
            )
          : null,
      Container(
        width: width / 2,
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Text("News", textAlign: TextAlign.center),
      )
    ]..removeWhere((w) => w == null));
    listTabBarView.addAll([
      user != null
          ? Center(
              child: FutureBuilder(
                  future:
                      notificationBloc.getYourNotification(user.accessToken),
                  builder: (context,
                      AsyncSnapshot<List<FreeMarNotification>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      if (snapshot.data.length > 0) {
                        return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) =>
                              _buildListItem(context, snapshot.data[index]),
                        );
                      } else {
                        return noData();
                      }
                    } else
                      return CircularProgressIndicator();
                  }),
            )
          : null,
      Center(
        child: FutureBuilder(
            future: notificationBloc.getSystemNotification(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                if (snapshot.data.length > 0) {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) =>
                        _buildListItem(context, snapshot.data[index]),
                  );
                } else {
                  return noData();
                }
              } else
                return CircularProgressIndicator();
            }),
      )
    ]..removeWhere((w) => w == null));
  }

  Widget _buildListItem(BuildContext context, FreeMarNotification data) {
    return Column(children: <Widget>[
      ListTile(
        leading: SizedBox(
          width: 64,
          height: 64,
          child: ClipRect(
            child: Material(
              color: Colors.transparent,
              child: Image.network(data.image),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              data.title,
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: AutoSizeText(
          data.body,
          style: Theme.of(context)
              .textTheme
              .subhead
              .copyWith(color: Color(0xFFBCBCBC)),
          minFontSize: 12,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          if (data.typeId == NotificationTypeEnum.ORDER) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SellManagerPage(initialTabIndex: 2),
              ),
            );
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => NotificationDetailPage(
                          data: data,
                        )));
          }
        },
      ),
      const Divider(height: 1.0, indent: 96.0)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var lang = S.of(context);
    return DefaultTabController(
      length: listTabBar.length,
      initialIndex: 0,
      child: Scaffold(
          drawer: CommonDrawer(user: user),
          appBar: AppBar(
            title: Text(lang.notifications),
            bottom: TabBar(
              isScrollable: true,
              labelColor: AppColors.tabSelected,
              unselectedLabelColor: AppColors.tabUnSelected,
              tabs: listTabBar,
            ),
          ),
          body: TabBarView(
            children: listTabBarView,
          ),
          floatingActionButton: CustomFloat(
            icon: Icons.camera_alt,
            qrCallback: () {
              if (user == null)
                requiredLogin(context);
              else
                Navigator.pushNamed(context, UIData.CREATE_PRODUCT);
            },
          )),
    );
  }
}
