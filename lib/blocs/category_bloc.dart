import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../models/Product/category.dart';
import '../providers/repository.dart';
import 'bloc_provider.dart';

class CategoryBloc implements BlocBase {
  final _repository = Repository();
  List<Category> _allCategories = <Category>[];
  List<Category> _leafCategoies = <Category>[];

  // Interface that allows to get the list of all Categories
  BehaviorSubject<List<Category>> _categoriesController =
      new BehaviorSubject<List<Category>>();

  Stream<List<Category>> get outCategories => _categoriesController.stream;

  getCategories() async {
    if (_allCategories.length == 0) {
      _allCategories = await _repository.getAllCategories();
    }

    if (!_categoriesController.isClosed)
      _categoriesController.sink.add(_allCategories);
  }

  searchCategories(String filterText) {
    if (filterText == "") {
      _categoriesController.sink.add(_allCategories);
    } else {
      if (_leafCategoies.length == 0) {
        _leafCategoies = _allCategories;
        List<Category> categories = _allCategories
            ?.where((e) => e.childrenObj != null && e.childrenObj.length > 0)
            ?.toList();
        for (int i = 0; i < categories.length; i++) {
          _leafCategoies.add(_getLeafCategories(categories[i]));
        }
      }
      _categoriesController.sink.add(_leafCategoies
          .where((e) =>
              e.name.toUpperCase().contains(filterText.trim().toUpperCase()))
          .toList());
    }
  }

  getCategoriesFromCache(){
    return _categoriesController.value;
  }

  Category _getLeafCategories(Category category) {
    if (category.childrenObj != null && category.childrenObj.length > 0)
      for (int i = 0; i < category.childrenObj.length; i++)
        return _getLeafCategories(category.childrenObj[i]);
    return category;
  }

  void dispose() {
    _categoriesController.close();
  }
}
