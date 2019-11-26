import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/search_bloc.dart';
import 'package:flutter_rentaza/models/Product/actions/product_search_template.dart';
import 'package:flutter_rentaza/models/Product/product.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/ui/pages/product/search/detailed_search.dart';
import 'package:flutter_rentaza/ui/widgets/product_gird.dart';

class SearchResults extends StatefulWidget {
  final SearchBloc searchBloc;
  final ProductSearchTemplate productSearchTemplate;

  SearchResults({Key key, this.searchBloc, this.productSearchTemplate})
      : super(key: key);

  @override
  _SearchResults createState() => new _SearchResults();
}

class _SearchResults extends State<SearchResults> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _showBottomSheet = new ValueNotifier(true);
  User _user = AppBloc().loginUser;

  @override
  void initState() {
    super.initState();
    widget.searchBloc.inSearch.add(widget.productSearchTemplate);
    _showBottomSheet.value = widget.productSearchTemplate.saved == false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        endDrawer: Drawer(
            child: DetailedSearch(
                drawer: true,
                searchBloc: widget.searchBloc,
                productSearchTemplate: widget.productSearchTemplate)),
        bottomSheet: _user != null
            ? ValueListenableBuilder(
                valueListenable: _showBottomSheet,
                builder: (context, value, _) {
                  if (value)
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          color: Colors.red,
                          child: Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: FlatButton.icon(
                                  onPressed: () {
                                    if (this.mounted) {
                                      widget.productSearchTemplate.saved = true;
                                      _showBottomSheet.value = false;
                                      widget.productSearchTemplate.create =
                                          true;
                                      widget.searchBloc.inSearch
                                          .add(widget.productSearchTemplate);
                                      widget.searchBloc.inSearchTemplate
                                          .add([widget.productSearchTemplate]);
                                    }
                                  },
                                  icon: Icon(Icons.star, color: Colors.white),
                                  label: Text(
                                    "Save Product Search",
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    );
                  return SizedBox();
                })
            : SizedBox(),
        body: DefaultTabController(
            length: 2,
            child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool boxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      title: TextField(
                        onChanged: _handleSearchTextChanged,
                        decoration: InputDecoration(
                          hintText: getProductSearchString(
                              widget.productSearchTemplate),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 18.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      pinned: true,
                      floating: true,
                      forceElevated: boxIsScrolled,
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(40.0),
                        child: Container(
                          margin: EdgeInsets.all(4.0),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    StreamBuilder<List<Product>>(
                                        stream:
                                            widget.searchBloc.outResultProducts,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Text(" " +
                                                snapshot.data.length
                                                    .toString());
                                          }
                                          return Text(" 0");
                                        }),
                                    Text(' results'),
                                  ],
                                ),
                              ),
//                              Align(
//                                alignment: Alignment.bottomRight,
//                                child: Row(
//                                  mainAxisSize: MainAxisSize.min,
//                                  mainAxisAlignment: MainAxisAlignment.end,
//                                  children: <Widget>[
//                                    Text('Filter by:'),
//                                    SizedBox(width: 8.0),
//                                    Container(
//                                      margin: const EdgeInsets.only(
//                                          top: 5.0, bottom: 5.0, right: 2.0),
//                                      padding: const EdgeInsets.symmetric(
//                                          horizontal: 6.0, vertical: 2.0),
//                                      decoration: BoxDecoration(
//                                        borderRadius:
//                                            BorderRadius.circular(24.0),
//                                        border: Border.all(
//                                            color: Color(0xff66543D)),
//                                      ),
//                                      child: StreamBuilder(
//                                          stream: _productBloc.outFilter,
//                                          builder: (BuildContext context,
//                                              AsyncSnapshot snapshot) {
//                                            return CustomDropdown
//                                                .DropdownButtonHideUnderline(
//                                              child: CustomDropdown
//                                                  .DropdownButton<String>(
//                                                isDense: true,
//                                                value: _currentItemSelected,
//                                                items: presetTags
//                                                    .map((f) => CustomDropdown
//                                                            .DropdownMenuItem<
//                                                                String>(
//                                                          child: Text(f),
//                                                          value: f,
//                                                        ))
//                                                    .toList(),
//                                                onChanged: (filter) =>
//                                                    _handleItemSelected(filter),
//                                              ),
//                                            );
//                                          }),
//                                    ),
//                                  ],
//                                ),
//                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ];
                },
                body: StreamBuilder<List<Product>>(
                    stream: widget.searchBloc.outResultProducts,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ProductGird(
                          blocUsed: false,
                          products: snapshot.data,
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    }))));
  }

  void _handleSearchTextChanged(String str) {
    if (str != '') {
      widget.productSearchTemplate.keyword = str;
      widget.searchBloc.inSearch.add(widget.productSearchTemplate);
      return;
    }
  }

  String getProductSearchString(ProductSearchTemplate item) {
    var rets = [];
    if ((item.keyword ?? "").isNotEmpty) rets.add(item.keyword);
    if ((item.categoryObjs ?? []).isNotEmpty)
      rets.add(item.categoryObjs.map((c) => c.toString()).join(" / "));
    if ((item.brandObjs ?? []).isNotEmpty)
      rets.add(item.brandObjs.map((c) => c.toString()).join(" / "));
    if ((item.colorAttributeObjs ?? []).isNotEmpty)
      rets.add(item.colorAttributeObjs.map((c) => c.toString()).join(" / "));

    return rets.join(", ");
  }

//  void _handleItemSelected(String newValueSelected) {
//    _currentItemSelected = newValueSelected;
//    _productBloc.loadFirstPage
//        .add(FilterBy(filter: newValueSelected, loadFirstPage: true));
//  }
}
