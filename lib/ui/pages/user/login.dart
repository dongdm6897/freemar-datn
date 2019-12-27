import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/login_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/ui/widgets/soical/facebook_signin_button.dart';
import 'package:flutter_rentaza/ui/widgets/soical/google_signin_button.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() {
    return new LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  bool isLoggedIn;

  LoginBloc loginBloc = LoginBloc();
  GoogleSignIn _googleSignIn = GoogleSignIn();
//  FacebookLogin facebookLogin = FacebookLogin();
  final _formKey = GlobalKey<FormState>();
  String _username;
  String _password;
  bool _saving = false;

  @override
  initState() {
    super.initState();
  }

//  onLoginFacebookStatusChanged(bool isLoggedIn, {profileData}) async {
//    if (isLoggedIn) {
//      setState(() {
//        _saving = true;
//      });
//      String id = profileData["id"];
//      String type = 'facebook';
//
//      Map params = Map();
//      params['data'] = {
//        "name": profileData['name'],
//        "email": profileData['email'],
//        "photoUrl": profileData['picture']['data']['url']
//      };
//      params['id'] = id;
//      params['type'] = type;
//
//      String token = await FirebaseMessaging().getToken();
//      params['fcm_token'] = token;
//
//      var response = await loginBloc.loginSocial(params);
//      if (response != null && response['user'] is User) {
//        User user = response['user'];
//        var accessToken = response['access_token'];
//        var expiresAt = response['expires_at'];
//        var res = await loginBloc.saveSharePref(true, user.id, accessToken);
//        if (res) {
//          user.name = user.snsData['name'];
//          user.avatar = user.snsData['photoUrl'];
//          user.accessToken = accessToken;
//          AppBloc().setLoginUser(user);
//          Navigator.pushNamed(context, UIData.HOMEPAGE);
//        } else
//          loginFail("Error ! Please try again");
//      } else {
//        setState(() {
//          _saving = false;
//        });
//        loginFail(response['message'] ?? "Error ! Please try again");
//      }
//    }
//  }

  onLoginGoogleStatusChanged(
      bool isLoggedIn, GoogleSignInAccount account) async {
    if (isLoggedIn) {
      setState(() {
        _saving = true;
      });
      Map params = Map();
      params['data'] = {
        "name": account.displayName,
        "email": account.email,
        "photoUrl": account.photoUrl
      };
      params['id'] = account.id;
      params['type'] = 'google';
      String token = await FirebaseMessaging().getToken();
      params['fcm_token'] = token;

      var response = await loginBloc.loginSocial(params);

      if (response != null && response['user'] is User) {
        User user = response['user'];
        var accessToken = response['access_token'];
        var expiresAt = response['expires_at'];
        var res = await loginBloc.saveSharePref(true, user.id, accessToken);
        if (res) {
          user.name = user.snsData['name'];
          user.avatar = user.snsData['photoUrl'];
          user.accessToken = accessToken;
          AppBloc().setLoginUser(user);
          Navigator.pushNamed(context, UIData.HOMEPAGE);
        } else
          loginFail("Error ! Please try again");
      } else {
        setState(() {
          _saving = false;
        });
        loginFail(response['message'] ?? "Error ! Please try again");
      }
    }
  }

  _submit() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      setState(() {
        _saving = true;
      });
      form.save();
      String username = _username.trim();
      var response = await loginBloc.login(username, _password);
      if (response != null && response['user'] is User) {
        User user = response['user'];
        var accessToken = response['access_token'];
        var expiresAt = response['expires_at'];
        var res = await loginBloc.saveSharePref(true, user.id, accessToken);
        if (res) {
          user.accessToken = accessToken;
          AppBloc().setLoginUser(user);
          Navigator.pushNamed(context, UIData.HOMEPAGE);
        } else
          loginFail("Error ! Please try again");
      } else {
        setState(() {
          _saving = false;
          isLoggedIn = false;
        });
        loginFail(
            response['message'] ?? S.current.username_or_password_is_incorrect);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        child: loginBody(context),
        inAsyncCall: _saving,
      ),
    );
  }

  loginBody(BuildContext context) => SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[loginHeader(context), loginFields(context)],
        ),
      );

  loginFail(String message) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget loginHeader(BuildContext context) {
    var lang = S.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const SizedBox(height: 10.0),
          Container(
              height: 150.0,
              padding: EdgeInsets.all(20.0),
              alignment: Alignment.center,
              child: Image.asset('assets/images/freemar_logo.png',
                  height: 150.0, width: double.infinity, fit: BoxFit.cover)),
          Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(5.0),
              height: 30.0,
              child: Text(
                "${UIData.APP_NAME} - Ứng dụng mua bán đồ cũ cực chất!",
                style:
                    TextStyle(fontWeight: FontWeight.w700, color: Colors.red),
              )),
//          isLoggedIn == false
//              ? Text(lang.username_or_password_is_incorrect,
//                  style: TextStyle(color: Colors.red))
//              : Text("")
        ],
      ),
    );
  }

  Widget loginFields(BuildContext context) {
    var lang = S.of(context);
    var size = MediaQuery.of(context).size;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
            child: TextFormField(
              maxLines: 1,
              decoration: InputDecoration(
                hintText: lang.enter_your_email,
                labelText: "Email",
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                Pattern pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regex = new RegExp(pattern);
                if (!regex.hasMatch(value)) return lang.please_enter_email;
                return null;
              },
              onSaved: (value) => _username = value,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
            child: TextFormField(
              maxLines: 1,
              obscureText: true,
              decoration: InputDecoration(
                hintText: lang.enter_your_password,
                labelText: lang.password,
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return lang.please_enter_password;
                }
                return null;
              },
              onSaved: (value) => _password = value,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FlatButton(
                onPressed: () {
                  Navigator.pushNamed(context, UIData.FORGET_PASSWORD);
                },
                child: Text(
                  lang.forget_password,
                  style: TextStyle(color: Colors.red[700]),
                )),
          ),
          SizedBox(
            height: 20.0,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
            width: double.infinity,
            child: RaisedButton(
              padding: EdgeInsets.all(12.0),
//              shape: BeveledRectangleBorder(
//                borderRadius: BorderRadius.circular(20.0),
//              ),
              child: Text(
                lang.sign_in,
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.red,
              onPressed: () {
                _submit();
              },
            ),
          ),
          const SizedBox(height: 5.0),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, UIData.SIGN_UP);
            },
            child: RichText(
                text: TextSpan(children: <TextSpan>[
              TextSpan(
                  text: "Không có tài khoản? ",
                  style: TextStyle(
                    color: Colors.black,
                  )),
              TextSpan(
                text: lang.sign_up_account,
                style: TextStyle(
                    color: Colors.green[700],
                    decoration: TextDecoration.underline),
              )
            ])),
          ),
          const SizedBox(height: 20.0),
          Row(children: <Widget>[
            Expanded(child: Divider()),
            Text("OR"),
            Expanded(child: Divider()),
          ]),
          const SizedBox(height: 10.0),
          Container(
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 4,
                    fit: FlexFit.tight,
                    child: FacebookSignInButton(onPressed: () {
//                      initiateFacebookLogin();
                    }),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Flexible(
                    flex: 4,
                    fit: FlexFit.tight,
                    child: GoogleSignInButton(onPressed: () {
                      _handleGoogleSignIn();
                    }),
                  )
                ],
              )),
        ],
      ),
    );
  }

//  void initiateFacebookLogin() async {
//    var facebookLoginResult =
//        await facebookLogin.logInWithReadPermissions(['email']);
//    switch (facebookLoginResult.status) {
//      case FacebookLoginStatus.error:
//        print("Error");
//        onLoginFacebookStatusChanged(false);
//        break;
//      case FacebookLoginStatus.cancelledByUser:
//        print("CancelledByUser");
//        onLoginFacebookStatusChanged(false);
//        break;
//      case FacebookLoginStatus.loggedIn:
//        print("LoggedIn");
//
//        var graphResponse = await http.get(
//            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${facebookLoginResult.accessToken.token}');
//
//        var profile = json.decode(graphResponse.body);
//        print(profile.toString());
//
//        onLoginFacebookStatusChanged(true, profileData: profile);
//        break;
//    }
//  }

  _handleGoogleSignIn() async {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      if (account != null) {
        onLoginGoogleStatusChanged(true, account);
      }
    });
    _googleSignIn.signInSilently();

    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }
}
