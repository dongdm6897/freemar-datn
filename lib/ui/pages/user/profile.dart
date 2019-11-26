import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/products_bloc.dart';
import 'package:flutter_rentaza/blocs/user_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Product/actions/product_tabs.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/ui/pages/user/user_authentication.dart';
import 'package:flutter_rentaza/ui/widgets/product_gird.dart';
import 'package:flutter_rentaza/ui/widgets/user_info.dart';
import 'package:flutter_rentaza/utils/colorful_app.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

// 0 - All Items
// 1 - Selling
const kExpandedHeight = 350.0;
const kUserInfoPanelHeight = 200.0;

class ProfilePage extends StatefulWidget {
  final User user;

  ProfilePage({Key key, this.user}) : super(key: key);

  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController;
  ProductBloc _productBloc;
  UserBloc _userBloc;
  int _currentItemSelected = 0;
  bool _disableClickDropDown = false;

  TabController _tabController;

  User _user;
  bool _isUserLogin = false;
  File _imageFont, _imageBack;

  PageController pageController = PageController();

  @override
  void initState() {
    _scrollController = ScrollController();
    _productBloc = ProductBloc();
    _userBloc = new UserBloc();

    //check guest
    if (widget.user.id == (AppBloc().loginUser?.id ?? -1)) {
      _user = AppBloc().loginUser;
      _isUserLogin = true;
    } else {
      _user = widget.user;
    }

    _tabController = TabController(
        vsync: this, initialIndex: 0, length: _isUserLogin ? 3 : 2);
    _tabController.addListener(_handleTabSelection);

    super.initState();
  }

  String _convertStatusToString() {
    if (_user.status == null) return "Simple";

    if (_user.status == UserStatus.ACTIVE) {
      return "High";
    }
    if (_user.status > UserStatus.ACTIVE && _user.status < UserStatus.MEDIUM) {
      return "Simple";
    }
    if (_user.status >= UserStatus.MEDIUM && _user.status < UserStatus.HIGH) {
      return "Medium";
    }
    if (_user.status >= UserStatus.HIGH) {
      return "High";
    }
    return null;
  }

  _handleTabSelection() {
    if (_tabController.index == 1 || _tabController.index == 2) {
      setState(() {
        _disableClickDropDown = true;
      });
    } else {
      setState(() {
        _disableClickDropDown = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _productBloc.dispose();
    _userBloc.dispose();
    _tabController.dispose();
  }

  bool get _showTitle {
    return _scrollController.hasClients &&
        _scrollController.offset >
            kExpandedHeight - kToolbarHeight - kUserInfoPanelHeight;
  }

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    var tabs = _buildTabs(context);
    var tabViews = <Widget>[
      PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: <Widget>[
          ProductGird(
              productTabs: ProductTabs(
                  name: ProductTabs.ACTION_OWNER,
                  tabId: _user.id,
                  pageSize: 10)),
          ProductGird(
              productTabs: ProductTabs(
                  name: ProductTabs.ACTION_SELLING,
                  tabId: _user.id,
                  pageSize: 10)),
        ],
      ),
      _buildProfileWidget(context),
    ];

    if (_isUserLogin) {
      tabs.add(Tab(text: lang.authentication));
      tabViews.add(UserAuthentication(
        user: _user,
        callback: ((file, typeImage) {
          switch (typeImage) {
            case imgBack:
              _imageBack = file;
              break;
            case imgFront:
              _imageFont = file;
              break;
            default:
              break;
          }
        }),
        imageFont: _imageFont,
        imageBack: _imageBack,
      ));
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[_buildAppBar(context, innerBoxIsScrolled, tabs)];
        },
        body: TabBarView(
          controller: _tabController,
          children: tabViews,
        ),
      ),
    );
  }

  Widget _buildProfileWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20.0,
              ),
            ]),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Self-introduction",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Divider(),
                Text(
                  _user?.introduction ?? "",
                  style: TextStyle(color: Colors.black),
                ),
                _isUserLogin
                    ? Align(
                        alignment: Alignment.bottomRight,
                        child: FlatButton(
                          child: Text(
                            "Edit your profile",
                            style: Theme.of(context)
                                .textTheme
                                .subhead
                                .copyWith(color: Colors.red),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, UIData.EDIT_PROFILE);
                          },
                        ),
                      )
                    : null,
              ]..removeWhere((f) => f == null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, bool innerBoxIsScrolled, List<Tab> tabs) {
    final lang = S.of(context);
    Color color = _showTitle ? Colors.black : Colors.white;

    return SliverAppBar(
      expandedHeight: kExpandedHeight,
      pinned: true,
      title: Text(
        lang.profile,
        style: TextStyle(color: color),
      ),
      forceElevated: innerBoxIsScrolled,
      iconTheme: IconThemeData(color: color),
      actionsIconTheme: IconThemeData(color: color),
      actions: <Widget>[
        IconButton(
          onPressed: () => Share.share('https://freemar.com/profile'),
          icon: Icon(Icons.share),
        ),
        _isUserLogin
            ? PopupMenuButton<int>(
                onSelected: (int result) {
                  switch (result) {
                    case 0:
                      Navigator.pushNamed(context, UIData.EDIT_PROFILE);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text(lang.edit_profile),
                  ),
                ],
              )
            : Container(),
      ],
      flexibleSpace: FlexibleSpaceBar(background: _buildContentWidget(context)),
      bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.tabSelected,
              unselectedLabelColor: AppColors.tabUnSelected,
              tabs: tabs,
            ),
          )),
    );
  }

  Widget _buildContentWidget(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Container(color: Colors.grey.shade400),
        _user?.coverImageLink != null
            ? Image.network(_user.coverImageLink, fit: BoxFit.cover)
            : Image.asset('assets/images/bg-summer.jpg',
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.darken,
                color: Colors.black.withOpacity(0.3)),
        Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
                padding: EdgeInsets.only(bottom: 50),
                color: Colors.white.withOpacity(0.8),
                width: size.width,
                child: UserInfoWidget(isSimpleMode: false, user: _user))),
      ],
    );
  }

  List<Tab> _buildTabs(BuildContext context) {
    final lang = S.of(context);

    return <Tab>[
      Tab(
          child: IgnorePointer(
        ignoring: _disableClickDropDown,
        child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
          isExpanded: true,
          value: _currentItemSelected,
          onChanged: (int newValue) {
            pageController.animateToPage(newValue,
                duration: Duration(milliseconds: 800),
                curve: Curves.fastOutSlowIn);
            setState(() {
              _currentItemSelected = newValue;
            });
          },
          items: [
            DropdownMenuItem<int>(
                value: 0,
                child: Text(
                  lang.all_items,
                  style: TextStyle(
                      color:
                          _currentItemSelected == 0 && _tabController.index == 0
                              ? AppColors.tabSelected
                              : AppColors.tabUnSelected),
                )),
            DropdownMenuItem<int>(
                value: 1,
                child: Text(
                  lang.product_selling,
                  style: TextStyle(
                      color:
                          _currentItemSelected == 1 && _tabController.index == 0
                              ? AppColors.tabSelected
                              : AppColors.tabUnSelected),
                )),
          ],
        )),
      )),
      Tab(text: lang.profile),
    ];
  }
}
