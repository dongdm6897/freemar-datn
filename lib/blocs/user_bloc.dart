import 'dart:async';
import 'dart:io';

import 'package:flutter_rentaza/blocs/bloc_provider.dart';
import 'package:flutter_rentaza/blocs/load_more_bloc.dart';
import 'package:flutter_rentaza/models/Product/product.dart';
import 'package:flutter_rentaza/models/User/shipping_address.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/providers/repository.dart';

class UserBloc extends ObjectsBloc implements BlocBase {
  final _repository = Repository();

  UserBloc() : super();

  @override
  Stream<ObjectListState> loadMoreData(dynamic action) async* {
    // get latest state
    final latestState = objectsList$.value;

    final currentList = latestState.objects;
    final currentPage = latestState.currentPage;
    // emit loading state
    yield latestState.copyWith(isLoading: true);

    try {
      var page;

      Map<String, String> params = Map<String, String>();
      params['page'] = currentPage.toString();
      params['page_size'] = "20";
      params['user_id'] = action['userId'].toString();

      if (action['getAllSeller'])
        page = await _repository.getAllSeller(params);
      else
        page = await _repository.getFollowUser(params);

      if (page.isEmpty) {
        // if page is empty, emit all paged loaded
        loadAllController.add(null);
      }

      // if fetch success, emit null
      errorController.add(null);
      var products = <User>[];
      if (!action['loadFirstPage']) {
        products = currentList;
      }
      products.addAll(page);
      // emit list state
      yield latestState.copyWith(
          isLoading: false,
          error: null,
          objects: products,
          currentPage: currentPage + 1);
    } catch (e) {
      // if error was occurred, emit error
      errorController.add(e);
      yield latestState.copyWith(
        isLoading: false,
        error: e,
      );
    } finally {}
  }

  verifyPhoto(
      String accessToken, int typeId, File imageFont, File imageBack) async {
    List<String> imageLinks =
        await _repository.uploadFiles([imageFont, imageBack], accessToken);
    Map params = Map();
    params['access_token'] = accessToken;
    params['font_image_link'] = imageLinks[0];
    params['back_image_link'] = imageLinks[1];
    params['type_id'] = typeId;

    bool res = await _repository.verifyPhoto(params);
    return res;
  }

  getPhotoVerified(String accessToken) {
    return _repository.getPhotoVerified({'access_token': accessToken});
  }

  verifyAddress(String address, String numberPhone, int userId) {
    Map<String, String> params = Map();
    params['address'] = address;
    params['number_phone'] = numberPhone;
    params['user_id'] = userId.toString();
//    _repository.emailValidation(params);
    return "05091997";
  }

  updateUserStatus(int userStatus, int userId) {
    Map<String, String> params = Map();
    params['user_status'] = userStatus.toString();
    params['user_id'] = userId.toString();
    _repository.updateUserStatus(params);
    return true;
  }

  Future<bool> setFavorite(User user, Product product) async {
    if (user.setFavorite(product.id)) {
      product.numberOfFavorites += 1;
      var params = {
        'user_id': user.id,
        'product_id': product.id,
        'access_token': user.accessToken,
        'is_favorite': true
      };
      product.numberOfFavorites = await _repository.setFavoriteProduct(params);
      return true;
    }

    return false;
  }

  Future<bool> clearFavorite(User user, Product product) async {
    if (user.clearFavorite(product.id)) {
      // TODO: Need return latest of numberOfFavorite value @Dat
      product.numberOfFavorites -= 1;

      var params = {
        'user_id': user.id,
        'product_id': product.id,
        'access_token': user.accessToken,
        'is_favorite': false
      };

      product.numberOfFavorites = await _repository.setFavoriteProduct(params);
      return true;
    }

    return false;
  }

  Future<bool> setFollower(User user, User followedUser) async {
    if (user.setFollower(followedUser)) {
      var params = {
        'user_id': user.id,
        'followed_user_id': followedUser.id,
        'is_follow': true,
        'access_token': user.accessToken
      };
      return _repository.setFollowerUser(params);
    }

    return false;
  }

  Future<bool> clearFollower(User user, User followedUser) async {
    if (user.clearFollower(followedUser.id)) {
      var params = {
        'user_id': user.id,
        'followed_user_id': followedUser.id,
        'is_follow': false,
        'access_token': user.accessToken
      };
      return _repository.setFollowerUser(params);
    }
    return false;
  }

  Future<bool> setWatched(User user, Product product) async {
    if (user != null && user.setWatched(product)) {
      var params = {
        'user_id': user.id,
        'access_token': user.accessToken,
        'product_id': product.id,
        'is_watched': true
      };
      return _repository.setWatchedProduct(params);
    }

    return false;
  }

  Future<dynamic> setUserInfo(User user, File avatar, File coverImage) async {
    if (avatar != null) {
      String avatarLink =
          await _repository.uploadFile(avatar, user.accessToken);
      user.avatar = avatarLink;
    }
    if (coverImage != null) {
      String coverImageLink =
          await _repository.uploadFile(coverImage, user.accessToken);
      user.coverImageLink = coverImageLink;
    }

    return await _repository.updateUserInfos(user.toJson());
  }

  Future<dynamic> notificationSettings(Map params) async {
    return await _repository.updateUserInfos(params);
  }

  Future<ShippingAddress> setNewShippingAddress(
      User user, ShippingAddress address) async {
    var params = address.toJson();
    params['user_id'] = user.id;
    params['access_token'] = user.accessToken;

    var newAddress = await _repository.updateShippingAddress(params);
    if (newAddress != null) {
      return newAddress;
    }

    return null;
  }

  Future<bool> deleteShippingAddress(User user, int shippingAddressId) async {
    Map params = Map();
    params['id'] = shippingAddressId;
    params['access_token'] = user.accessToken;
    bool res = await _repository.deleteShippingAddress(params);
    return res;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
