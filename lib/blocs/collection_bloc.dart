import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../models/Product/collection.dart';
import '../providers/repository.dart';
import 'bloc_provider.dart';

class CollectionBloc implements BlocBase {
  final _repository = Repository();
  List<Collection> _allCollection;

  // Interface that allows to get the list of all Categories
  BehaviorSubject<List<Collection>> _collectionController =
      new BehaviorSubject<List<Collection>>();
  Stream<List<Collection>> get outCollections => _collectionController.stream;

  getCollections() async {
    if (_allCollection == null) {
      _allCollection = await _repository.getAllCollections();
      _collectionController.sink.add(_allCollection);
    }
  }

  void dispose() {
    _collectionController.close();
  }
}
