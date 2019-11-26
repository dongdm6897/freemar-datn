import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/search_bloc.dart';
import 'package:flutter_rentaza/models/Product/actions/product_search_template.dart';
import 'package:flutter_rentaza/models/Product/actions/search_history.dart';
import 'package:flutter_rentaza/models/Product/brand.dart';
import 'package:flutter_rentaza/models/Product/category.dart';
import 'package:flutter_rentaza/ui/pages/product/search/search_results.dart';
import 'package:flutter_rentaza/ui/widgets/search_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SearchAll extends StatefulWidget {
  @override
  _SearchAll createState() => _SearchAll();
}

class _SearchAll extends State<SearchAll> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  ProductSearchTemplate _productSearchTemplate = ProductSearchTemplate();

  SearchBloc _searchBloc;

  final _searching = ValueNotifier(false);

  List<SearchHistory> searchHistories;

  @override
  void initState() {
    super.initState();
    _searchBloc = new SearchBloc();
    _searchBloc.outSearchResult.listen((data) {
      if (data != null) _searching.value = false;
    });
    searchHistories = AppBloc().loginUser?.searchHistories??[];
  }

  @override
  void dispose() {
    _searchBloc.dispose();
    super.dispose();
  }

  void _handleSearchTextChanged(String str) {
    if (str != '' && str.length >= 3) {
      _searching.value = true;
      _productSearchTemplate.keyword = str;
      _searchBloc.inSearch.add(str);
      return;
    }
  }

  Widget buildSearchResult(BuildContext context, List<Widget> data) {
    return ListView(
      children: data,
    );
  }

  _handleClick(BuildContext context) {
//    _searchBloc.inSearch.add(_productSearchTemplate);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResults(
          searchBloc: _searchBloc,
          productSearchTemplate: _productSearchTemplate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchBar(
          onChange: _handleSearchTextChanged,
          onSubmitted: (String value){

            if(searchHistories.length > 0)
              {
                if(searchHistories.firstWhere((s) => s.content == value,orElse: () => null) == null)
                {
                  searchHistories.add(SearchHistory(content: value));
                  _searchBloc.saveSearchHistory(value);
                }
              }
            _productSearchTemplate.keyword = value;
            _handleClick(context);
          },
          autoFocus: true,
        ),
      ),
      body: ValueListenableBuilder(
          valueListenable: _searching,
          builder: (context, value, _) {
            return ModalProgressHUD(
                inAsyncCall: value,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: StreamBuilder(
                      stream: _searchBloc.outSearchResult,
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasData) {
                          var results = snapshot.data;
                          var brands = results['brands']['data'];
                          var categories = results['categories']['data'];
                          var products = results['products']['data'];
                          List<Widget> listTitle = [];
                          if (brands != null && brands.length > 0) {
                            listTitle.add(Align(
                              alignment: Alignment.bottomLeft,
                              child: Text('Thương Hiệu'),
                            ));
                            results['brands']['data']
                                .forEach((f) => listTitle.add(
                                      ListTile(
                                        leading: Icon(MdiIcons.sourceBranch),
                                        title: Text(f['name']),
                                        onTap: () {
                                          _productSearchTemplate.brandObjs = [
                                            new Brand.fromJSON(f)
                                          ];
                                          _productSearchTemplate.keyword = null;
                                          _handleClick(context);
                                        },
                                      ),
                                    ));
                            listTitle.add(Divider());
                          }
                          if (categories != null && categories.length > 0) {
                            listTitle.add(Align(
                              alignment: Alignment.bottomLeft,
                              child: Text('Thể Loại'),
                            ));
                            results['categories']['data']
                                .forEach((f) => listTitle.add(
                                      ListTile(
                                        leading: Icon(MdiIcons.shapeOutline),
                                        title: Text(f['name']),
                                        onTap: () {
                                          _productSearchTemplate.categoryObjs =
                                              [new Category.fromJSON(f)];
                                          _productSearchTemplate.keyword = null;
                                          _handleClick(context);
                                        },
                                      ),
                                    ));
                            listTitle.add(Divider());
                          }
                          if (products != null && products.length > 0) {
                            listTitle.add(Align(
                              alignment: Alignment.bottomLeft,
                              child: Text('Products'),
                            ));
                            products
                                .forEach((f) => listTitle.add(
                                      ListTile(
                                        leading: Icon(Icons.search),
                                        title: Text(f['name']),
                                        onTap: () {
                                          _productSearchTemplate.keyword =
                                              f['name'];
                                          _handleClick(context);
                                        },
                                      ),
                                    ));
                          }
                          if (results != null)
                            return buildSearchResult(context, listTitle);
                        }

                        return Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text('Lịch sử tìm kiếm'),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: searchHistories.length,
                                  itemBuilder:(BuildContext context, int idx){
                                    return InkWell(
                                      child: ListTile(
                                        leading: Icon(Icons.search),
                                        title: Text(searchHistories[idx].content),
//                                        trailing: GestureDetector(
//                                          onTap: (){
//                                            AppBloc().loginUser.searchHistories.removeAt(idx);
//                                            setState(() {
//
//                                            });
//                                          },
//                                          child: Icon(Icons.close),
//                                        ),
                                      ),
                                      onTap: (){
                                        _productSearchTemplate.keyword = AppBloc().loginUser.searchHistories[idx].content;
                                        _handleClick(context);
                                      },
                                    );
                                  }),
                            ),
                          ],
                        );
//                        return Center(
//                          child: noData(),
//                        );
                      }),
                ));
          }),
    );
  }
}
