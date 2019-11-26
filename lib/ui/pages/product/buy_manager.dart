import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Product/actions/product_tabs.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/ui/pages/utils/help_screen.dart';
import 'package:flutter_rentaza/ui/widgets/common_drawer.dart';
import 'package:flutter_rentaza/ui/widgets/product_list.dart';
import 'package:flutter_rentaza/utils/colorful_app.dart';

class BuyManagerPage extends StatefulWidget {
  @override
  _BuyManagerPageState createState() => _BuyManagerPageState();
}

class _BuyManagerPageState extends State<BuyManagerPage> {
  List<Widget> _listTabs;
  List<Widget> _listTabBarView;
  AppBloc _appBloc;

  @override
  void initState() {
    _appBloc = AppBloc();
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
        Tab(text: lang.product_buying),
        Tab(text: lang.product_bought)
      ];

    if (_listTabBarView == null)
      _listTabBarView = [
        ProductList(
            productTabs: ProductTabs(
                name: ProductTabs.ACTION_BUYING,
                tabId: AppBloc().loginUser?.id,
                pageSize: 10)),
        ProductList(
            productTabs: ProductTabs(
                name: ProductTabs.ACTION_BOUGHT,
                tabId: AppBloc().loginUser?.id,
                pageSize: 10))
      ];

    return Scaffold(
      drawer: CommonDrawer(user: user),
      body: DefaultTabController(
          length: 2,
          initialIndex: 0,
          child: Scaffold(
              appBar: AppBar(
                title: Text(lang.product_buy_manager),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.help_outline),
                    onPressed: () {
                      var route = MaterialPageRoute(
                          builder: (BuildContext context) => new HelpScreen(
                              title: 'HELP: About buy manager screen',
                              url: _appBloc.links["help3"]));
                      Navigator.of(context).push(route);
                    },
                  )
                ],
                bottom: TabBar(
                  tabs: _listTabs,
                  isScrollable: true,
                  labelColor: AppColors.tabSelected,
                  unselectedLabelColor: AppColors.tabUnSelected,
                ),
              ),
              body: TabBarView(children: _listTabBarView))),
    );
  }
}
