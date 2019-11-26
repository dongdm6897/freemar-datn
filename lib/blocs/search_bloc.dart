import 'dart:async';

import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/models/Product/actions/product_search_template.dart';
import 'package:flutter_rentaza/models/Product/product.dart';
import 'package:flutter_rentaza/providers/repository.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc_provider.dart';

class SearchBloc implements BlocBase {
  final _repository = Repository();
  final _appBloc = AppBloc();

  List<dynamic> _results = <dynamic>[];
  List<ProductSearchTemplate> _listProductSearch = <ProductSearchTemplate>[];

  //Key Word
  PublishSubject<dynamic> _searchController = new PublishSubject<dynamic>();

  Sink<dynamic> get inSearch => _searchController.sink;

  // Return Products
  PublishSubject<List<Product>> _resultProducts =
      new PublishSubject<List<Product>>();

  Sink<List<Product>> get _inResultProducts => _resultProducts.sink;

  Stream<List<Product>> get outResultProducts => _resultProducts.stream;

  // Return Search
  PublishSubject<dynamic> _searchResult = new PublishSubject<dynamic>();

  Sink<dynamic> get _inSearchResult => _searchResult.sink;

  Stream<dynamic> get outSearchResult => _searchResult.stream;

  PublishSubject<List<ProductSearchTemplate>> _searchTemplate =
      new PublishSubject<List<ProductSearchTemplate>>();

  Sink<List<ProductSearchTemplate>> get inSearchTemplate =>
      _searchTemplate.sink;

  Stream<List<ProductSearchTemplate>> get outSearchTemplate =>
      _searchTemplate.stream;

  SearchBloc() {
    _searchController.listen(_handleSearch);
  }

  void dispose() {
    _searchController.close();
    _searchResult.close();
    _resultProducts.close();
    _searchTemplate.close();
  }

  getAllResults() async {}

  getAllProductSearchTpl() async {
    _repository.getProductSearchTmp({'user_id': _appBloc.loginUser.id}).then(
        (onValue) {
      _listProductSearch = onValue;
      if (!_searchTemplate.isClosed) inSearchTemplate.add(_listProductSearch);
    });
  }

  saveSearchHistory(String name){
    _repository.saveSearchHistory({
      'content':name,
      'access_token': _appBloc.loginUser.accessToken
    });
  }

  deleteProductSearchTpl(ProductSearchTemplate event) {
    Map params = Map();
    //delete local
    _listProductSearch.remove(event);
    inSearchTemplate.add(_listProductSearch);

    //delete sever
    params['id'] = event.id;
    params['access_token'] = _appBloc.loginUser.accessToken;
    _repository.deleteSearchProduct(params);
  }

  Future _handleSearch(dynamic event) async {
    if (event is ProductSearchTemplate) {
      print("event create search product ${event.create}");
      if (event.create) {
        //request post data,save search product template
        Map params = event.toJson();
        params['access_token'] = _appBloc.loginUser.accessToken;
        bool response = await _repository.createSearchProduct(params);
      } else {
        Map params = event.toJson();
        List<Product> resBrands = <Product>[]; //result product
        resBrands = await _repository.searchProduct(params);
        if(!_resultProducts.isClosed) _inResultProducts.add(resBrands);
      }
    } else if (event is String) {
      var res = await _repository.searchKeyword(event);
      if(!_resultProducts.isClosed) _inSearchResult.add(res);
    }
  }
}
