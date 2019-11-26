import 'dart:async';
import 'dart:io';

import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/load_more_bloc.dart';
import 'package:flutter_rentaza/models/Product/actions/filter_by.dart';
import 'package:flutter_rentaza/models/Product/actions/product_search_template.dart';
import 'package:flutter_rentaza/models/Product/actions/product_tabs.dart';

import '../models/Product/product.dart';
import '../providers/repository.dart';

class ProductBloc extends ObjectsBloc {
  final _repository = Repository();

  //handle filter
  StreamController<FilterBy> _filterController =
      StreamController<FilterBy>.broadcast();

  Sink<FilterBy> get _addFilter => _filterController.sink;

  Stream<FilterBy> get outFilter => _filterController.stream;

  ProductBloc() : super();

  @override
  Stream<ObjectListState> loadMoreData(dynamic action) async* {
    // get latest state
    final latestState = objectsList$.value;

    final currentList = latestState.objects;
    int currentPage = latestState.currentPage;

    if (action.loadFirstPage) currentPage = 1;

    // emit loading state
    yield latestState.copyWith(isLoading: true);

    try {
      var page;
      // fetch page from data source
      switch (action.runtimeType) {
        case ProductTabs:
          page = await _loadTabs(action, currentPage);
          break;
        case ProductSearchTemplate:
          page = await _searchProduct(action);
          break;
        case FilterBy:
          page = await _onFilterBy(action);
          break;
        default:
          break;
      }

      if (page.isEmpty) {
        // if page is empty, emit all paged loaded
        loadAllController.add(null);
      }

      // if fetch success, emit null
      errorController.add(null);
      var products = <Product>[];
      if (!action.loadFirstPage) {
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

  Future _loadTabs(ProductTabs action, int currentPage) async {
    Map<String, String> params = Map<String, String>();
    params['page'] = currentPage.toString();
    params['page_size'] = action.pageSize.toString();

    var currentUser = AppBloc().loginUser;

    switch (action.name) {
      case ProductTabs.ACTION_NEW:
        return _repository.getNewProducts(params);
      case ProductTabs.ACTION_RECENT:
        return await _repository.getRecentlyProducts(params);
      case ProductTabs.ACTION_FREE:
        return await _repository.getFreeProducts(params);
      case ProductTabs.ACTION_OWNER:
        params['user_id'] = action.tabId.toString();
        var result = _repository.getProductOwner(params);
        return result;
      case ProductTabs.ACTION_DRAFT:
        params['access_token'] = currentUser?.accessToken;
        var result = _repository.getDraftProducts(params);
        return result;
      case ProductTabs.ACTION_SELLING:
        params['user_id'] = action.tabId.toString();
        var result = _repository.getSellingProducts(params);
        return result;
      case ProductTabs.ACTION_ORDERING:
        params['user_id'] = action.tabId.toString();
        var result = _repository.getOrderingProducts(params);
        return result;
      case ProductTabs.ACTION_ORDERING_AUTH:
        params['access_token'] = currentUser?.accessToken;
        params['user_id'] = action.tabId.toString();
        var result = _repository.getOrderingAuthProducts(params);
        return result;
      case ProductTabs.ACTION_SOLD:
        params['user_id'] = currentUser?.id?.toString();
        var result = _repository.getSoldProducts(params);
        return result;
      case ProductTabs.ACTION_SOLD_AUTH:
        params['user_id'] = action.tabId.toString();
        params['access_token'] = currentUser?.accessToken;
        var result = _repository.getSoldAuthProducts(params);
        return result;
      case ProductTabs.ACTION_BUYING:
        params['access_token'] = currentUser?.accessToken;
        return _repository.getBuyingProducts(params);
      case ProductTabs.ACTION_BOUGHT:
        params['access_token'] = currentUser?.accessToken;
        return _repository.getBoughtProducts(params);
      case ProductTabs.ACTION_FAVORITE:
        params['user_id'] = currentUser?.id?.toString();
        return _repository.getFavoriteProducts(params);
      case ProductTabs.ACTION_COMMENT:
        params['user_id'] = currentUser?.id?.toString();
        return _repository.getCommentedProducts(params);
      case ProductTabs.ACTION_RELATED:
        int productId = action.tabId;
        params['product_id'] = productId.toString();
        return _repository.getRelatedProducts(params);
      case ProductTabs.ACTION_WATCHED:
        int userId = action.tabId;
        params['user_id'] = userId.toString();
        return _repository.getWatchedProducts(params);
      case ProductTabs.ACTION_BRAND:
        int brandId = action.tabId;
        params['brand_id'] = brandId.toString();
        return _repository.getProductBrand(params);
      case ProductTabs.ACTION_COLLECTION:
        int colectionId = action.tabId;
        params['collection_id'] = colectionId.toString();
        return _repository.getProductCollection(params);
      case ProductTabs.ACTION_CATEGORY:
        int categoryId = action.tabId;
        params['category_id'] = categoryId.toString();
        return _repository.getProductCategory(params);
      default:
        return _repository.getAllProducts(params);
    }
  }

  Future _searchProduct(ProductSearchTemplate action) async {
    var products = [];
    products = await _repository.getAllProducts(null);
    for (var i = 0; i < products.length; i++) {
      if (products[i]
          .name
          .toString()
          .toLowerCase()
          .contains(action.keyword.toLowerCase())) {
        products.remove(products[i]);
      }
    }
    return products;
  }

  Future<Product> updateProduct(Product product,
      {Map<int, String> images}) async {
    var currentUser = AppBloc().loginUser;
    // Re-upload new images
    if (images != null) {
      // Upload new modified images (images without http)
      var modifiedImages = Map<int, String>();
      var unmodifiedImages = Map<int, String>();
      images.forEach((k, v) {
        var tmp = k < (product.referenceImageLinks?.length ?? -1)
            ? product.referenceImageLinks?.elementAt(k)
            : null;
        if (tmp != v)
          modifiedImages[k] = v;
        else if (tmp != null) unmodifiedImages[k] = v;
      });

//      var results = await Future.wait(modifiedImages
//          .map((k, v) => MapEntry(
//              k, _repository.uploadFile(File(v), currentUser.accessToken)))
//          .values);
      List<File> files = <File>[];
      modifiedImages.forEach((k, v) {
        files.add(File(v));
      });
      List<String> results =
          await _repository.uploadFiles(files, currentUser.accessToken);
      if (results != null) {
        product.referenceImageLinks = new List.from(results)
          ..addAll(unmodifiedImages.values);
      }
      product.representImage ??= product.referenceImageLinks?.elementAt(0);
    }
    // Update modified product informations
    return await _repository.updateProduct(
        {'product': product.toJson(), 'access_token': currentUser.accessToken});
  }

  Future<bool> deleteProduct(int id) async {
    var currentUser = AppBloc().loginUser;
    return await _repository
        .deleteProduct({'id': id, 'access_token': currentUser.accessToken});
  }

  Future _onFilterBy(FilterBy action) async {
    _addFilter.add(action);
    var products = [];
    final latestState = objectsList$.value;
    products = latestState.objects;
    products.sort((a, b) => a.price.compareTo(b.price));
    return products;
  }

  dispose() async {
    _filterController.close();
    super.dispose();
  }
}
