import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/products_bloc.dart';
import 'package:flutter_rentaza/models/Product/actions/product_tabs.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/ui/pages/product/search/search_all.dart';
import 'package:flutter_rentaza/ui/widgets/collection_list.dart';
import 'package:flutter_rentaza/ui/widgets/common_drawer.dart';
import 'package:flutter_rentaza/ui/widgets/custom_float.dart';
import 'package:flutter_rentaza/ui/widgets/follow_user_list.dart';
import 'package:flutter_rentaza/ui/widgets/product_gird.dart';
import 'package:flutter_rentaza/ui/widgets/required_login.dart';
import 'package:flutter_rentaza/ui/widgets/search_bar.dart';
import 'package:flutter_rentaza/utils/colorful_app.dart';
import 'package:flutter_rentaza/utils/string_utils.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';
import 'package:flutter_rentaza/generated/i18n.dart';

class ShoppingPage extends StatefulWidget {
  @override
  _ShoppingPage createState() => _ShoppingPage();
}

class _ShoppingPage extends State<ShoppingPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ProductBloc productBloc;
  User user = AppBloc().loginUser;
  int tabsFavoriteBrands = 0;
  int tabsFavoriteCategories = 0;

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
    var lang = S.of(context);

    final widthScreen = MediaQuery.of(context).size.width;
    List<Widget> listTabs = [
      Container(
        width: widthScreen / 3,
        child: Tab(text: lang.recent),
      ),
      Container(
        width: widthScreen / 3,
        child: Tab(text: S.of(context).new_products),
      ),
      // Container(
      //   width: widthScreen / 3,
      //   child: Tab(text: 'Collection'),
      // ),
      Container(
        width: widthScreen / 3,
        child: Tab(text: lang.give_and_take),
      ),
      // user != null
      //     ? Container(
      //         width: widthScreen / 3,
      //         child: Tab(text: 'Follows'),
      //       )
      //     : null,
      user != null
          ? Container(
              width: widthScreen / 3,
              child: Tab(text: S.of(context).favorite_products),
            )
          : null,
    ]..removeWhere((f) => f == null);
    List<Widget> listTabBarView = [
      ProductGird(
        productTabs: ProductTabs(name: ProductTabs.ACTION_RECENT, pageSize: 10),
        ads: true,
      ),
      ProductGird(
        productTabs: ProductTabs(name: ProductTabs.ACTION_NEW, pageSize: 10),
        ads: true,
      ),
      // CollectionListWidget(),
      ProductGird(
        productTabs: ProductTabs(name: ProductTabs.ACTION_FREE, pageSize: 10),
        ads: true,
      ),
      // user != null ? FollowUserList(getAllSeller: false) : null,
      user != null
          ? ProductGird(
              productTabs: ProductTabs(name: ProductTabs.ACTION_FAVORITE, pageSize: 10))
          : null,
    ]..removeWhere((f) => f == null);
    if (user != null) {
      tabsFavoriteBrands = user.favoriteBrandObjs?.length ?? 0;
      for (int i = 0; i < tabsFavoriteBrands; i++) {
        listTabs.add(Container(
          width: widthScreen / 3,
          child: Tab(text: user.favoriteBrandObjs[i].name),
        ));
        listTabBarView.add(ProductGird(
            productTabs: ProductTabs(
                tabId: user.favoriteBrandObjs[i].id,
                pageSize: 10,
                name: ProductTabs.ACTION_BRAND)));
      }

      tabsFavoriteCategories = user.favoriteCategoryObjs?.length ?? 0;

      for (int i = 0; i < tabsFavoriteCategories; i++) {
        listTabs.add(Container(
          width: widthScreen / 3,
          child:
              Tab(text: getLeafCategoryName(user.favoriteCategoryObjs[i].name)),
        ));
        listTabBarView.add(ProductGird(
            productTabs: ProductTabs(
                tabId: user.favoriteCategoryObjs[i].id,
                pageSize: 10,
                name: ProductTabs.ACTION_CATEGORY)));
      }
    }
    return DefaultTabController(
        length: listTabs.length,
        initialIndex: 1,
        child: Scaffold(
          drawer: CommonDrawer(user: user),
          appBar: AppBar(
            title: SearchBar(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchAll(),
                  ),
                );
              },
            ),
            bottom: TabBar(
              isScrollable: true,
              tabs: listTabs,
              labelColor: AppColors.tabSelected,
              unselectedLabelColor: AppColors.tabUnSelected,
            ),
          ),
          body: TabBarView(children: listTabBarView),
          floatingActionButton: CustomFloat(
            icon: Icons.camera_alt,
            qrCallback: () {
              if (user == null)
                requiredLogin(context);
              else
                Navigator.pushNamed(context, UIData.CREATE_PRODUCT);
            },
          ),
        ));
  }
}
