import 'dart:async';

import 'package:flutter_rentaza/blocs/bloc_provider.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingBloc implements BlocBase {
  saveProductColumn(int horizontal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var wColumn =
        await prefs.setInt(UIData.PRODUCT_COLUMN_VERTICAL, horizontal);
    if (wColumn) {
      return true;
    } else {
      return false;
    }
  }

  Future<int> getProductColumn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var wColumn = await prefs.get(UIData.PRODUCT_COLUMN_VERTICAL);
    if (wColumn != null && wColumn > 0) {
      return wColumn;
    } else {
      return 2;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}
