import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';

import '../models/Product/brand.dart';
import '../providers/repository.dart';
import 'bloc_provider.dart';

class BrandBloc implements BlocBase {
  final _repository = Repository();

  List<Brand> _brands;

  // Interface that allows to add a new brand
  BehaviorSubject<Brand> _brandAddController = new BehaviorSubject<Brand>();

  Sink<Brand> get inAddBrand => _brandAddController.sink;

  // Interface that allows to remove a brand from the list of brands
  BehaviorSubject<Brand> _brandRemoveController = new BehaviorSubject<Brand>();

  Sink<Brand> get inBrand => _brandRemoveController.sink;

  // Interface that allows to get the list of all brands
  BehaviorSubject<List<Brand>> _brandsController =
      new BehaviorSubject<List<Brand>>();

  Sink<List<Brand>> get _inBrands => _brandsController.sink;

  Stream<List<Brand>> get outBrands => _brandsController.stream;

  BrandBloc() {
    _brandAddController.listen(_handleAddBrand);
    _brandRemoveController.listen(_handleRemoveBrand);
  }

  getBrands() async {
    if (_brands == null) {
      _brands = await _repository.getAllBrands();
    }
    if (!_brandsController.isClosed) _brandsController.sink.add(_brands);
  }

  searchBrand(String filterText) {
    if (filterText != "") {
      filterText = filterText.toUpperCase().trim();
      List<Brand> brands = _brands
          .where((e) =>
              e.name.toUpperCase().contains(filterText) ||
              e.description.toUpperCase().contains(filterText))
          ?.toList();
      if (!_brandsController.isClosed) _brandsController.sink.add(brands);
    }
  }

  void dispose() {
    _brandAddController.close();
    _brandRemoveController.close();
    _brandsController.close();
  }

  // ############# HANDLING  #####################

  void _handleAddBrand(Brand brand) {
    _brands.add(brand);

    _notify();
  }

  void _handleRemoveBrand(Brand brand) {
    _brands.remove(brand);

    _notify();
  }

  void _notify() {
    // The new list of all brand
    _inBrands.add(UnmodifiableListView(_brands));
  }
}
