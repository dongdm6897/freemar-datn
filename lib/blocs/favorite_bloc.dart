import 'dart:async';

import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/models/Product/brand.dart';
import 'package:flutter_rentaza/models/Product/category.dart';
import 'package:flutter_rentaza/providers/repository.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc_provider.dart';

class FavoriteBloc implements BlocBase {
  final _repository = Repository();

  // Interface that allow to get the list of all brands
  BehaviorSubject<bool> _favoritesController = new BehaviorSubject<bool>();

  Sink<bool> get addFavorites => _favoritesController.sink;

  Stream<bool> get outFavorites => _favoritesController.stream;

  addFavoriteBrand(Brand brand) async {
    var user = AppBloc().loginUser;
    if (user != null) {
      Map params = Map();
      params['user_id'] = user.id;
      params['brand_id'] = brand.id;
      params['access_token'] = user.accessToken;
      var res = await _repository.addFavoriteBrand(params);
      return res;
    }
    return false;
  }

  deleteFavoriteBrand(Brand brand) async {
    var user = AppBloc().loginUser;
    if (user != null) {
      Map params = Map();
      params['user_id'] = user.id;
      params['brand_id'] = brand.id;
      params['access_token'] = user.accessToken;
      var res = await _repository.deleteFavoriteBrand(params);
      return res;
    }
    return false;
  }

  addFavoriteCategory(Category category) async {
    var user = AppBloc().loginUser;
    if (user != null) {
      Map params = Map();
      params['user_id'] = user.id;
      params['category_id'] = category.id;
      params['access_token'] = user.accessToken;
      var res = await _repository.addFavoriteCategory(params);
      return res;
    }
    return true;
  }

  deleteFavoriteCategory(Category category) async {
    var user = AppBloc().loginUser;
    if (user != null) {
      Map params = Map();
      params['user_id'] = user.id;
      params['category_id'] = category.id;
      params['access_token'] = user.accessToken;
      var res = await _repository.deleteFavoriteCategory(params);
      return res;
    }
    return false;
  }

  getFavoriteBrands() async {
    var user = AppBloc().loginUser;
    if (user != null) {
      Map params = Map();
      params['user_id'] = user.id;
      var res = await _repository.getFavoriteBrands(params);
      return res;
    }
    return null;
  }

  void dispose() {
    _favoritesController.close();
  }
}
