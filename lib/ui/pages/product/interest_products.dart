import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Product/actions/product_tabs.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/ui/widgets/common_drawer.dart';
import 'package:flutter_rentaza/ui/widgets/product_gird.dart';
import 'package:flutter_rentaza/utils/colorful_app.dart';

class InterestProductPage extends StatefulWidget {
  @override
  _InterestProductPageState createState() => _InterestProductPageState();
}

class _InterestProductPageState extends State<InterestProductPage> {
  List<Widget> _listTabs;
  List<Widget> _listTabBarView;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = AppBloc().loginUser;
    var lang = S.of(context);

    if (_listTabs == null)
      _listTabs = [
        Tab(text: lang.product_favorite),
        Tab(text: lang.product_commented),
        Tab(text: lang.product_watched),
      ];

    if (_listTabBarView == null)
      _listTabBarView = [
        ProductGird(
            productTabs: ProductTabs(
                name: ProductTabs.ACTION_FAVORITE,
                tabId: AppBloc().loginUser?.id,
                pageSize: 10)),
        ProductGird(
            productTabs: ProductTabs(
                name: ProductTabs.ACTION_COMMENT,
                tabId: AppBloc().loginUser?.id,
                pageSize: 10)),
        ProductGird(
            productTabs: ProductTabs(
                name: ProductTabs.ACTION_WATCHED,
                tabId: AppBloc().loginUser?.id,
                pageSize: 10))
      ];

    return Scaffold(
        drawer: CommonDrawer(user: user),
        body: DefaultTabController(
            length: 3,
            initialIndex: 0,
            child: Scaffold(
                appBar: AppBar(
                  title: Text(lang.product_interest),
                  bottom: TabBar(
                    tabs: _listTabs,
                    isScrollable: true,
                    labelColor: AppColors.tabSelected,
                    unselectedLabelColor: AppColors.tabUnSelected,
                  ),
                ),
                body: TabBarView(children: _listTabBarView))));
  }
}
