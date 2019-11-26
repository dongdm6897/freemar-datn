import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../models/Product/rank.dart';
import '../providers/repository.dart';
import 'bloc_provider.dart';

class RankBloc implements BlocBase {
  final _repository = Repository();
  List<Rank> _allRanks;

  // Interface that allows to get the list of all Categories
  PublishSubject<List<Rank>> _rankController = new PublishSubject<List<Rank>>();

  Stream<List<Rank>> get outRanks => _rankController.stream;

  Sink<List<Rank>> get addRanks => _rankController.sink;

  getRanks() async {
    if (_allRanks == null) {
      _allRanks = await _repository.getAllRanks();
    }
    if (!_rankController.isClosed) addRanks.add(_allRanks);
  }

  void dispose() {
    _rankController.close();
  }
}
