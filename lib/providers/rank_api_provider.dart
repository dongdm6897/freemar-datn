import 'dart:async';

import 'package:flutter/foundation.dart' show compute;

import '../models/Product/rank.dart';
import 'api_list.dart';
import 'api_provider.dart';

class RankApiProvider extends ApiProvider {
  RankApiProvider() : super() {
//    mockupDataPath = 'assets/json/ranking.json';
    apiUrlSuffix = '/rank';
  }

  Future<List<Rank>> getRanks() async {
    var jsonData =
        await this.getData(ApiList.API_RANK_GET_ALL, null, root: 'all');
    // Extract items from json data
    return compute(parseRanks, {"json": jsonData});
  }

  // Isolate implementations
  static List<Rank> parseRanks(dynamic params) {
    final json = params["json"];

    if (json != null) {
      return new List<Rank>.from(json.map((e) => Rank.fromJSON(e)));
    }

    return null;
  }
}
