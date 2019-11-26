import 'dart:async';

import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/providers/api_list.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_provider.dart';

class LoginApiProvider extends ApiProvider {
  LoginApiProvider() : super() {
    apiUrlSuffix = "/auth";
  }

  Future<dynamic> login(Map<String, String> params) async {
    var response = await this.postData(ApiList.API_LOGIN, params);
    if (response != null) {
        return response;
    }
    return null;
  }

  Future<dynamic> loginSocial(Map profile) async {
    var response = await this.postData(ApiList.API_LOGIN_SOCIAL, profile);
    if (response != null) {
      return response;
    }
    return null;
  }

  Future<dynamic> signUp(Map<String, String> params) async {
    var response = await this.postData(ApiList.API_SIGN_UP, params);
    if (response != null) {
      String message = response["message"];
      return message;
    }
    return null;
  }

  Future saveSharePref(bool isLoggedIn, int id, String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var wLogged = await prefs.setBool(UIData.LOGGED_IN_PREF, isLoggedIn);
    var wId = await prefs.setInt(UIData.USER_ID, id);
    var waccessToken = await prefs.setString(UIData.ACCESS_TOKEN, accessToken);
    if (wLogged && wId && waccessToken) {
      return true;
    } else {
      return false;
    }
  }

  Future deleteSharePref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var wLogged = await prefs.remove(UIData.LOGGED_IN_PREF);
    var wId = await prefs.remove(UIData.USER_ID);
    if (wLogged && wId) {
      return true;
    } else {
      return false;
    }
  }

  Future saveLocalData(bool isLoggedIn, String name, String email, String id,
      String avatar) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var wLogged = await prefs.setBool(UIData.LOGGED_IN_PREF, isLoggedIn);
    var wName = await prefs.setString(UIData.USER_NAME, name);
    var wEmail = await prefs.setString(UIData.EMAIL, email);
    var wId = await prefs.setString(UIData.SOCIAL_ID, id);
    var wAvatar = await prefs.setString(UIData.AVATAR, avatar);
    if (wLogged && wName & wAvatar && wEmail && wId) {
      return true;
    } else {
      return false;
    }
  }

  Future deleteLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var wLogged = await prefs.remove(UIData.LOGGED_IN_PREF);
    var wName = await prefs.remove(UIData.USER_NAME);
    var wEmail = await prefs.remove(UIData.EMAIL);
    var wId = await prefs.remove(UIData.EMAIL);
    var wAvatar = await prefs.remove(UIData.AVATAR);
    if (wLogged && wName & wAvatar && wEmail && wId) {
      return true;
    } else {
      return false;
    }
  }

  Future getLogged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var rLogged = await prefs.get(UIData.LOGGED_IN_PREF);
    var rId = await prefs.get(UIData.USER_ID);
    var rAccessToken = await prefs.get(UIData.ACCESS_TOKEN);
    if (rLogged != null &&
        rLogged == true &&
        rId != null &&
        rAccessToken != null) {
      return {'id': rId, 'access_token': rAccessToken};
    } else {
      return null;
    }
  }

  Future<dynamic> getProfile(Map data) async {
    Map<String, String> params = Map<String, String>();
    params["user_id"] = data["id"].toString();
    params['access_token'] = data["access_token"];
    var jsonData =
        await this.getData(ApiList.API_GET_PROFILE, params, root: 'user');
    // Extract items from json data
    if (jsonData != null) {
      User user = User.fromJSON(jsonData);
      user.accessToken = data["access_token"];
      if (user.snsData != null) {
        user.name = user.snsData['name'];
        user.avatar = user.avatar = user.snsData['photoUrl'];
      }
      return user;
    }

    return null;
  }
}
