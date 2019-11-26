import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/favorite_bloc.dart';
import 'package:flutter_rentaza/blocs/search_bloc.dart';
import 'package:flutter_rentaza/models/Product/actions/product_search_template.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/ui/pages/product/search/search_results.dart';
import 'package:flutter_rentaza/ui/widgets/brand_list.dart';
import 'package:flutter_rentaza/ui/widgets/category_list.dart';
import 'package:flutter_rentaza/ui/widgets/list_cell.dart';
import 'package:flutter_rentaza/utils/icons_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_rentaza/generated/i18n.dart';

class FavoriteSearch extends StatefulWidget {
  final SearchBloc searchBloc;
  final User user;

  const FavoriteSearch({Key key, this.searchBloc, this.user}) : super(key: key);

  @override
  FavoriteSearchState createState() {
    return FavoriteSearchState();
  }
}

class FavoriteSearchState extends State<FavoriteSearch> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  double _initHeight;

  double _heightSaveSearch;

  User _user;
  List<Widget> _favoriteBrand;
  List<Widget> _favoriteCategory;
  FavoriteBloc _favoriteBloc;

  @override
  void initState() {
    _favoriteBloc = FavoriteBloc();
    _initHeight = 75.0;
    _heightSaveSearch = 75.0;

    //get all product search template
    widget.searchBloc.getAllProductSearchTpl();

    //end
    super.initState();
  }

  @override
  void dispose() {
    _favoriteBloc.dispose();
    super.dispose();
  }

  _initData() {
    _user = widget.user ?? AppBloc().loginUser;
    //initial favorite brands
    _favoriteBrand = <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text(
              S.of(context).favorite_brands,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: () async {
              try {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return BrandListWidget(isOnlyFavoriteMode: true);
                  },
                );
                setState(() {});
              } catch (FormatException) {}
            },
            child: Icon(
              FontAwesomeIcons.plus,
              size: 18.0,
            ),
          )
        ],
      ),
      Divider(),
    ];

    //initial favorite categories
    _favoriteCategory = <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text(
              S.of(context).favorite_categories,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: () async {
              try {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CategoryListWidget(isOnlyFavoriteMode: true);
                  },
                );
                setState(() {});
              } catch (FormatException) {}
            },
            child: Icon(
              FontAwesomeIcons.plus,
              size: 18.0,
            ),
          )
        ],
      ),
      Divider(),
    ];

    if (_user != null) {
      if (_user.favoriteBrandObjs != null) {
        for (int i = 0; i < _user.favoriteBrandObjs.length; i++) {
          _favoriteBrand.add(GestureDetector(
            child: Dismissible(
                key: Key(_user.favoriteBrandObjs[i].id.toString()),
                onDismissed: (DismissDirection direction) async {
                  _favoriteBloc.deleteFavoriteBrand(_user.favoriteBrandObjs[i]);
                  _user.favoriteBrandObjs.removeAt(i);
                },
                background: Container(
                  color: Colors.redAccent,
                  child: Icon(Icons.delete),
                ),
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Row(children: <Widget>[
//              Icon(Icons.favorite),
                    Image.network(
                      _user.favoriteBrandObjs[i].image,
                      width: 25,
                      height: 25,
                    ),
                    Padding(padding: EdgeInsets.all(5.0)),
                    Text(
                      _user.favoriteBrandObjs[i].name,
                    )
                  ]),
                )),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchResults(
                    searchBloc: widget.searchBloc,
                    productSearchTemplate: ProductSearchTemplate(
                        brandObjs: [_user.favoriteBrandObjs[i]]),
                  ),
                ),
              );
            },
          ));
        }
      }

      if (_user.favoriteCategoryObjs != null) {
        for (int i = 0; i < _user.favoriteCategoryObjs.length; i++) {
          _favoriteCategory.add(
            GestureDetector(
              child: Dismissible(
                  key: Key(_user.favoriteCategoryObjs[i].id.toString()),
                  onDismissed: (DismissDirection direction) async {
                    _favoriteBloc
                        .deleteFavoriteCategory(_user.favoriteCategoryObjs[i]);
                    _user.favoriteCategoryObjs.removeAt(i);
                  },
                  background: Container(
                    color: Colors.greenAccent,
                    child: Icon(Icons.delete),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Row(children: <Widget>[
                      Icon(
                          getMdiIcon(_user.favoriteCategoryObjs[i].icon) ??
                              Icons.folder_open,
                          size: 24.0),
                      Padding(padding: EdgeInsets.all(5.0)),
                      Expanded(
                          child: Text(
                        _user.favoriteCategoryObjs[i].toString(),
                        overflow: TextOverflow.ellipsis,
                      ))
                    ]),
                  )),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResults(
                      searchBloc: widget.searchBloc,
                      productSearchTemplate: ProductSearchTemplate(
                          categoryObjs: [_user.favoriteCategoryObjs[i]]),
                    ),
                  ),
                );
              },
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initData();
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
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      S.of(context).saved_search_criteria,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        height: _heightSaveSearch,
                        child: StreamBuilder<List<ProductSearchTemplate>>(
                            stream: widget.searchBloc.outSearchTemplate,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<ProductSearchTemplate>>
                                    snapshot) {
                              if (snapshot.hasData) {
                                _heightSaveSearch =
                                    snapshot.data.length * _initHeight;
                                return ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data.length,
                                    itemBuilder:
                                        (BuildContext content, int index) {
                                      var res = snapshot.data[index];
                                      return ListCell(
                                        leading: Icon(Icons.search),
                                        title: res.name,
                                        subtitle:
                                            '${res.keyword != null ? 'keyword : ${res.keyword}, ' : ''}${(res.brandObjs != null && res.brandObjs.length > 0) ? 'brand : ${res.brandObjs.toString()}, ' : ''}${(res.categoryObjs != null && res.categoryObjs.length > 0) ? 'categories : ${res.categoryObjs.toString()}' : ''}',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchResults(
                                                searchBloc: widget.searchBloc,
                                                productSearchTemplate: res,
                                              ),
                                            ),
                                          );
                                        },
                                        trailing: IconButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("Delete ?"),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text("Cancel"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    FlatButton(
                                                      child: Text("Delete"),
                                                      onPressed: () {
                                                        widget.searchBloc
                                                            .deleteProductSearchTpl(
                                                                snapshot.data[
                                                                    index]);
                                                        setState(() {
                                                          _heightSaveSearch =
                                                              _heightSaveSearch -
                                                                  _initHeight;
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          tooltip: 'Delete',
                                          icon: Icon(Icons.more_vert),
                                        ),
                                      );
                                    });
                              }
                              return SizedBox();
                            }),
                      );
                    },
                  ),
                ],
              )),
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
                children: _favoriteBrand),
          ),
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
                children: _favoriteCategory),
          ),
        ],
      ),
    );
  }
}
