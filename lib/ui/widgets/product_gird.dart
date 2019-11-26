import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/load_more_bloc.dart';
import 'package:flutter_rentaza/blocs/products_bloc.dart';
import 'package:flutter_rentaza/blocs/setting_bloc.dart';
import 'package:flutter_rentaza/blocs/user_bloc.dart';
import 'package:flutter_rentaza/models/Product/actions/product_search_template.dart';
import 'package:flutter_rentaza/models/Product/actions/product_tabs.dart';
import 'package:flutter_rentaza/models/Product/product.dart';
import 'package:flutter_rentaza/models/Sale/ads.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/ui/pages/product/product_detail.dart';
import 'package:flutter_rentaza/ui/pages/utils/help_screen.dart';
import 'package:flutter_rentaza/ui/widgets/required_login.dart';
import 'package:flutter_rentaza/utils/custom_style.dart';
import 'package:flutter_rentaza/utils/icons_helper.dart';
import 'package:flutter_rentaza/utils/no_data.dart';
import 'package:flutter_rentaza/utils/string_utils.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:simple_logger/simple_logger.dart';

class ProductGird extends StatefulWidget {
  final ProductTabs productTabs;
  final bool blocUsed;
  final List<Product> products;
  final ProductSearchTemplate productSearchTemplate;
  final ScrollController scrollController;
  final ScrollPhysics physics;
  final bool ads;

  ProductGird(
      {this.blocUsed = true,
      this.productTabs,
      this.products,
      this.productSearchTemplate,
      this.scrollController,
      this.physics = const AlwaysScrollableScrollPhysics(),
      this.ads = false});

  @override
  ProductGirdState createState() {
    return ProductGirdState();
  }
}

class ProductGirdState extends State<ProductGird>
    with AutomaticKeepAliveClientMixin {
  final SimpleLogger _logger = SimpleLogger()..mode = LoggerMode.print;

  var _selectedOption;
  int _loadMorePage = 0;
  User _user;
  static const offsetVisibleThreshold = 50;
  ScrollController _scrollController = ScrollController();
  ProductBloc _productBloc;
  SettingBloc _settingBloc;
  int columnVertical = 2;
  UserBloc _userBloc;

  @override
  void initState() {
    _logger.info(
        "initState STARTED..., blocUsed: ${widget.blocUsed}, tab: ${widget.productTabs?.name}");
    _productBloc = ProductBloc();
    _userBloc = new UserBloc();
    _settingBloc = SettingBloc();

    _user = AppBloc().loginUser;
    if (widget.blocUsed) {
      _selectedOption = widget.productTabs != null
          ? widget.productTabs
          : widget.productSearchTemplate;
      _selectedOption.loadFirstPage = true;
      _productBloc.loadFirstPage.add(_selectedOption);

      if (_selectedOption.pageSize != null && _selectedOption.pageSize > 1) {
        _scrollController.addListener(_onScroll);
        _loadMorePage = 2;
      }
    }

    _settingBloc.getProductColumn().then((onValue) {
      if (onValue != null && onValue > 0) {
        if (this.mounted)
          setState(() {
            columnVertical = onValue;
          });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _settingBloc.dispose();
    _userBloc.dispose();
    _productBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      child: StreamBuilder<ObjectListState>(
        stream: widget.blocUsed
            ? _productBloc?.objectsList
            : new Stream<ObjectListState>.fromIterable([
                ObjectListState(
                    objects: List.unmodifiable(widget.products),
                    isLoading: false,
                    error: null,
                    currentPage: 0)
              ]),
        builder: (context, AsyncSnapshot<ObjectListState> snapshot) {
          if (snapshot.hasData) {
            bool isLoading = snapshot.data.isLoading;
            if (isLoading && snapshot.data.objects.length == 0)
              return Center(child: CircularProgressIndicator());
            else if (snapshot.data.objects.length == 0)
              return Center(child: noData());
            else if (snapshot.data.objects.length > 0) {
              return LayoutBuilder(builder: (context, constraints) {
                Widget loading = widget.products != null
                    ? SizedBox()
                    : Positioned(
                        top: _selectedOption.loadFirstPage ? 0.0 : null,
                        bottom: 0.0,
                        right: width / 2 - 30.0,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: Opacity(
                              child: CircularProgressIndicator(),
                              opacity: isLoading ? 1 : 0,
                            ),
                          ),
                        ));
                if (constraints.maxWidth < 600) {
                  if (columnVertical == 2) {
                    return Stack(
                      children: <Widget>[
                        productGrid2(snapshot, context),
                        isLoading ? loading : SizedBox()
                      ],
                    );
                  } else {
                    return Stack(
                      children: <Widget>[
                        productGrid3(snapshot, context),
                        isLoading ? loading : SizedBox()
                      ],
                    );
                  }
                } else {
                  return Stack(
                    children: <Widget>[
                      productGrid3(snapshot, context),
                      isLoading ? loading : SizedBox()
                    ],
                  );
                }
              });
            }
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      onRefresh: () async {
        _selectedOption.loadFirstPage = true;
        _productBloc.loadFirstPage.add(_selectedOption);
        await Future.delayed(Duration(seconds: 0), () {});
      },
    );
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      AppBloc().eventSink.add(
          {'type': NotificationTypeEnum.SHOW_HIDE_BOTTOM_BAR, 'hide': true});
      if (_scrollController.offset + offsetVisibleThreshold >=
          _scrollController.position.maxScrollExtent) {
        _selectedOption.loadFirstPage = false;
        _productBloc.loadMore.add(_selectedOption);
      }
    }
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      AppBloc().eventSink.add(
          {'type': NotificationTypeEnum.SHOW_HIDE_BOTTOM_BAR, 'hide': false});
    }
  }

  Widget productGrid2(
      AsyncSnapshot<ObjectListState> snapshot, BuildContext context) {
    final products = snapshot.data.objects;
    int addItems = widget.ads ? 1 : 0;
    return StaggeredGridView.countBuilder(
        controller: _scrollController,
        physics: widget.physics,
        shrinkWrap: true,
        crossAxisCount: 2,
        itemCount: addItems + products.length + _loadMorePage,
        padding: const EdgeInsets.all(2.0),
        itemBuilder: (BuildContext context, int index) {
          if (index < (products.length + addItems) && index > (addItems - 1)) {
            Product product = products[index - addItems];
            return InkWell(
                splashColor: Colors.blueGrey.withOpacity(0.2),
                onTap: () {
                  var route = MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ProductDetailPage(product: product));
                  Navigator.of(context).push(route);
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20.0,
                        ),
                      ]),
                  margin: EdgeInsets.all(5.0),
                  child: Column(
                    children: <Widget>[
                      Stack(
                        fit: StackFit.passthrough,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(5.0),
                                topLeft: Radius.circular(5.0)),
                            child: imageStack(product.representImage,
                                product.isOrdering, product.isSoldOut),
                          ),
                          loveStack2(product),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: descStack2(product),
                      )
                    ],
                  ),
                ));
          } else if (index == 0) {
            return advertisement();
          }
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              height: 50.0,
            ),
          );
        },
        staggeredTileBuilder: (int index) =>
            StaggeredTile.fit(widget.ads && index == 0 ? 2 : 1));
  }

  Widget productGrid3(
      AsyncSnapshot<ObjectListState> snapshot, BuildContext context) {
    final products = snapshot.data.objects;
    int addItems = widget.ads ? 1 : 0;
    return StaggeredGridView.countBuilder(
        controller: _scrollController,
        physics: widget.physics,
        shrinkWrap: true,
        crossAxisCount: 3,
        itemCount: addItems + products.length + _loadMorePage,
        padding: const EdgeInsets.all(2.0),
        itemBuilder: (BuildContext context, int index) {
          if (index < (products.length + addItems) && index > (addItems - 1)) {
            Product product = products[index - addItems];
            return InkWell(
                splashColor: Colors.blueGrey.withOpacity(0.2),
                onTap: () {
                  var route = MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ProductDetailPage(product: product));
                  Navigator.of(context).push(route);
                },
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Stack(fit: StackFit.passthrough, children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(),
                      child: imageStack(product.representImage,
                          product.isOrdering, product.isSoldOut),
                    ),
                    Positioned(
                        bottom: 10.0,
                        left: 5.0,
                        child: descStack3(product)),
                    loveStack3(product),
                  ]),
                ));
          } else if (index == 0) {
            return advertisement();
          }
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              height: 50.0,
            ),
          );
        },
        staggeredTileBuilder: (int index) =>
            StaggeredTile.fit(widget.ads && index == 0 ? 3 : 1));
  }

  Widget imageStack(String img, bool isOrdering, bool isSoldOut) {
    Widget loadImage = CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: img,
        placeholder: (context, url) =>
            Center(child: new CircularProgressIndicator()),
        errorWidget: (context, url, error) => new Icon(Icons.error));
    return (isOrdering || isSoldOut)
        ? Banner(
            message: "SOLD OUT",
            location: BannerLocation.topStart,
            color: Colors.red,
            child: loadImage,
          )
        : loadImage;
  }

  Widget loveStack3(Product product) {
    var isFavorited = (_user != null) ? _user.checkFavorite(product.id) : false;

    return Positioned(
      bottom: 10.0,
      right: 0.0,
      child: InkWell(
        onTap: () {
          if (this.mounted) {
            if (_user != null) {
              setState(() {
                if (!isFavorited) {
                  _userBloc.setFavorite(_user, product);
                } else {
                  _userBloc.clearFavorite(_user, product);
                }
              });
            } else {
              requiredLogin(context);
            }
          }
        },
        child: Container(
          padding: EdgeInsets.all(4.0),
          child: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : Colors.white,
            size: 16.0,
          ),
        ),
      ),
    );
  }

  Widget loveStack2(Product product) {
    var isFavorited = (_user != null) ? _user.checkFavorite(product.id) : false;
    return Positioned(
      bottom: 0.0,
      right: 0.0,
      child: InkWell(
        onTap: () async {
          if (this.mounted) {
            if (_user != null) {
              setState(() {
                if (!isFavorited) {
                  _userBloc.setFavorite(_user, product);
                } else {
                  _userBloc.clearFavorite(_user, product);
                }
              });
            } else {
              requiredLogin(context);
            }
          }
        },
        child: Container(
          padding: EdgeInsets.all(4.0),
          child: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : Colors.white,
            size: 24.0,
          ),
        ),
      ),
    );
  }

  Widget descStack2(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          product.name,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.black),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                  fit: FlexFit.tight,
                  child: Text(
                      formatCurrency(product.price,
                          useNatureExpression: true),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold))),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.comment,
//                      color: CustomStyle.iconInterest,
                    size: 14.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 3.0, right: 5.0),
                    child: Text(product.numberOfComments?.toString() ?? "0",
                        style: CustomTextStyle.labelInformation(context)),
                  ),
                  Icon(
                    getIconUsingPrefix(name: 'solidHeart'),
//                      color: CustomStyle.iconInterest,
                    size: 14.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 3.0, right: 5.0),
                    child: Text(product.numberOfFavorites?.toString() ?? "0",
                        style: CustomTextStyle.labelInformation(context)),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget descStack3(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          product.name,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white, fontSize: 10.0),
        ),
        Text(
            formatCurrency(product.price,
                useNatureExpression: true),
            style: TextStyle(
                color: Colors.white,
                fontSize: 10.0,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget advertisement() {
    Ads _ads = (AppBloc().ads..shuffle()).first;
    return InkWell(
      child: Container(
        height: 75,
        child: CachedNetworkImage(
            imageUrl: _ads.imageLink,
            fit: BoxFit.fitWidth,
            placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
            errorWidget: (context, url, error) => new Icon(Icons.error)),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => HelpScreen(
                  title: _ads.title,
                  url: _ads.url,
                )));
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive =>
      widget.productTabs?.name == ProductTabs.ACTION_FAVORITE ? false : true;
}
