import 'dart:async';

import 'api_list.dart';
import 'api_provider.dart';

class AppApiProvider extends ApiProvider {
  AppApiProvider() : super() {
//    mockupDataPath = 'assets/json/app.json';
    apiUrlSuffix = "";
  }

  Future<dynamic> getMasterDatas() async {
    var jsonData = await this.getData(ApiList.API_GET_MASTER_DATA, null);
    return jsonData;
  }
}
