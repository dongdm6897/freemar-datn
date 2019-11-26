import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/login_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/ui/pages/product/home.dart';
import 'package:flutter_rentaza/ui/pages/user/login.dart';
import 'package:flutter_rentaza/ui/pages/user/profile.dart';
import 'package:flutter_rentaza/ui/pages/utils/help_screen.dart';
import 'package:flutter_rentaza/ui/widgets/follow_user_list.dart';
import 'package:flutter_rentaza/ui/widgets/required_login.dart';
import 'package:flutter_rentaza/ui/widgets/user_info.dart';
import 'package:flutter_rentaza/utils/colorful_app.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';

class CommonDrawer extends StatefulWidget {
  final User user;

  CommonDrawer({this.user});

  @override
  CommonDrawerState createState() {
    return new CommonDrawerState();
  }
}

class CommonDrawerState extends State<CommonDrawer> {
  AppBloc _appBloc;
  User _user;

  @override
  void initState() {
    _appBloc = AppBloc();
    _user = widget.user ?? _appBloc.loginUser;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lang = S.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (_user != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                              user: _user,
                            )));
              } else {
                requiredLogin(context);
              }
            },
            child: SizedBox(
              height: 200.0,
              child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                      image: _user?.coverImageLink != null
                          ? NetworkImage(_user.coverImageLink)
                          : ExactAssetImage('assets/images/bg-summer.jpg'),
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3), BlendMode.dstATop),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: (_user != null)
                      ? UserInfoWidget(
                          user: _user, isSideMode: true, isSimpleMode: true)
                      : Container(
                          child: Center(
                              child: RaisedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()));
                            },
                            color: Colors.redAccent,
                            child: Text(
                              "Login",
                              style: TextStyle(color: AppColors.textWhite),
                            ),
                          )),
                        )),
            ),
          ),
          _user != null
              ? Column(
                  children: <Widget>[
                    new ListTile(
                        title: Text(
                          "All seller list",
                        ),
                        leading: Icon(
                          Icons.people,
                        ),
                        onTap: () {
                          var route = MaterialPageRoute(
                              builder: (BuildContext context) => new Scaffold(
                                  appBar: new AppBar(
                                    title: new Text(S.of(context).all_seller_list),
                                  ),
                                  body: FollowUserList()));
                          Navigator.of(context).push(route);
                        }),
                    Divider(),
                    new ListTile(
                      title: Text(
                        lang.product_interest,
                      ),
                      leading: Icon(
                        Icons.favorite,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, UIData.INTEREST_PRODUCTS);
                      },
                    ),
                    new ListTile(
                      title: Text(
                        lang.product_sell_manager,
                      ),
                      leading: Icon(
                        Icons.store,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, UIData.SELL_MANAGER);
                      },
                    ),
                    new ListTile(
                      title: Text(
                        lang.product_buy_manager,
                      ),
                      leading: Icon(
                        Icons.shopping_cart,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, UIData.BUY_MANAGER);
                      },
                    ),
                    Divider(),
                    new ListTile(
                      title: Text(
                        lang.revenue,
                      ),
                      leading: Icon(
                        Icons.monetization_on,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, UIData.ACCOUNT_MANAGER);
                      },
                    ),
                    Divider()
                  ],
                )
              : null,
          new ListTile(
            title: Text(
              S.of(context).settings,
            ),
            leading: Icon(
              Icons.settings,
            ),
            onTap: () {
              Navigator.pushNamed(context, UIData.SETTINGS);
            },
          ),
          new ListTile(
            title: Text(
              S.of(context).help,
            ),
            leading: Icon(
              Icons.help_outline,
            ),
            onTap: () {
              var route = MaterialPageRoute(
                  builder: (BuildContext context) => new HelpScreen(
                      title: 'BaiBai help center!',
                      url: _appBloc.links["help1"]));
              Navigator.of(context).push(route);
            },
          ),
          new ListTile(
            title: Text(
              "Phản hồi",
            ),
            leading: Icon(
              Icons.feedback,
            ),
            onTap: () {
              var route = MaterialPageRoute(
                  builder: (BuildContext context) => new HelpScreen(
                      title: 'Phản hồi về baibai.vn',
                      url: _appBloc.links["feedback1"]));
              Navigator.of(context).push(route);
            },
          ),
          _user != null
              ? Column(
                  children: <Widget>[
                    Divider(),
                    ListTile(
                      title: Text(
                        S.of(context).log_out,
                      ),
                      leading: Icon(
                        Icons.close,
                      ),
                      onTap: () {
                        LoginBloc loginBloc = LoginBloc();
                        loginBloc.deleteLocalData();
                        AppBloc().setLogoutUser();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      },
                    )
                  ],
                )
              : null,
        ]..removeWhere((widget) => widget == null),
      ),
    );
  }
}
