import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Product/actions/product_tabs.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/ui/pages/utils/help_screen.dart';
import 'package:flutter_rentaza/ui/widgets/common_drawer.dart';
import 'package:flutter_rentaza/ui/widgets/custom_float.dart';
import 'package:flutter_rentaza/ui/widgets/product_list.dart';
import 'package:flutter_rentaza/utils/colorful_app.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';

class SellManagerPage extends StatefulWidget {
  final int initialTabIndex;

  const SellManagerPage({Key key, this.initialTabIndex}) : super(key: key);

  @override
  _SellManagerPageState createState() => _SellManagerPageState();
}

class _SellManagerPageState extends State<SellManagerPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Widget> _listTabs;
  List<Widget> _listTabBarView;
  int _selectedTabIndex;
  AppBloc _appBloc;

  @override
  void initState() {
    _appBloc = AppBloc();
    _selectedTabIndex = widget.initialTabIndex ?? 0;

    _tabController =
        TabController(vsync: this, length: 4, initialIndex: _selectedTabIndex)
          ..addListener(() {
            if (this.mounted) {
              setState(() {
                _selectedTabIndex = _tabController.index;
              });
            }
          });
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
        Tab(text: lang.product_draft),
        Tab(text: lang.product_selling),
        Tab(text: lang.product_ordering),
        Tab(text: lang.product_sold)
      ];

    //TODO: get products
    if (_listTabBarView == null)
      _listTabBarView = [
        ProductList(
            productTabs:
                ProductTabs(name: ProductTabs.ACTION_DRAFT, pageSize: 10)),
        ProductList(
            productTabs: ProductTabs(
                name: ProductTabs.ACTION_SELLING,
                tabId: AppBloc().loginUser?.id,
                pageSize: 10)),
        ProductList(
            productTabs: ProductTabs(
                name: ProductTabs.ACTION_ORDERING_AUTH,
                tabId: AppBloc().loginUser?.id,
                pageSize: 10)),
        ProductList(
            productTabs: ProductTabs(
                name: ProductTabs.ACTION_SOLD_AUTH,
                tabId: AppBloc().loginUser?.id,
                pageSize: 10))
      ];

    return Scaffold(
      drawer: CommonDrawer(user: user),
      body: DefaultTabController(
          length: 4,
          initialIndex: _selectedTabIndex,
          child: Scaffold(
              appBar: AppBar(
                title: Text(lang.product_sell_manager),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.help_outline),
                    onPressed: () {
                      var route = MaterialPageRoute(
                          builder: (BuildContext context) => new HelpScreen(
                              title: 'HELP: About sell manager screen',
                              url: _appBloc.links["help3"]));
                      Navigator.of(context).push(route);
                    },
                  )
                ],
                bottom: TabBar(
                  controller: _tabController,
                  tabs: _listTabs,
                  isScrollable: true,
                  labelColor: AppColors.tabSelected,
                  unselectedLabelColor: AppColors.tabUnSelected,
                ),
              ),
              body: TabBarView(
                children: _listTabBarView,
                controller: _tabController,
              ))),
      floatingActionButton: _selectedTabIndex < 2
          ? CustomFloat(
              icon: Icons.camera_alt,
              qrCallback: () {
                Navigator.pushNamed(context, UIData.CREATE_PRODUCT);
              },
            )
          : null,
    );
  }
}
