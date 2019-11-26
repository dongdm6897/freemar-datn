import 'dart:async';

import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/bloc_provider.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/providers/repository.dart';

class LoginBloc implements BlocBase {
  final _repository = Repository();

  saveSharePref(bool isLoggedIn, int id, String accessToken) {
    return _repository.saveSharePref(isLoggedIn, id, accessToken);
  }

  deleteLocalData() {
    return _repository.deleteLocalData();
  }

  getLogged() {
    return _repository.getLogged();
  }

  getProfile(Map data) {
    return _repository.getProfile(data);
  }

  Future<dynamic> login(String username, String password) async {
    Map<String, String> params = Map<String, String>();
    params['email'] = username;
    params['password'] = password;
    params['fcm_token'] = AppBloc().fcmToken;
    var response = await _repository.login(params);
    if (response['user'] != null)
      response['user'] = User.fromJSON(response['user']);
    return response;
  }

  Future<dynamic> loginSocial(Map profile) async {
    var response = await _repository.loginSocial(profile);
    if (response['user'] != null)
      response['user'] = User.fromJSON(response['user']);
    return response;
  }

  signUp(Map<String, String> data) {
    var response = _repository.signUp(data);
    return response;
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}
