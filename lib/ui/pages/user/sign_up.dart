import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/login_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SignupPage extends StatefulWidget {
  @override
  SignupPageState createState() {
    return new SignupPageState();
  }
}

class SignupPageState extends State<SignupPage> {
  LoginBloc loginBloc = LoginBloc();
  final _formKey = GlobalKey<FormState>();
  FocusNode passwordFocus, confirmPasswordFocus;
  TextEditingController _username, _password, _confirmPassword, _email;
  bool _signUp = false;

  @override
  initState() {
    super.initState();
    passwordFocus = FocusNode();
    confirmPasswordFocus = FocusNode();
    _username = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    _email = TextEditingController();
  }

  @override
  dispose() {
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    _username.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future _submit() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      setState(() {
        _signUp = true;
      });
      Map<String, String> data = Map<String, String>();
      await FirebaseMessaging().getToken().then((token) {
        if (token != null) {
          data = {
            "name": _username.text.trim(),
            "email": _email.text.trim(),
            "password": _password.text,
            "password_confirmation": _confirmPassword.text,
            "fcm_token": token
          };
        }
      });
      if (data != null) {
        var statusCode = await loginBloc.signUp(data);
        if (statusCode != null) {
          setState(() {
            _signUp = false;
          });
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text('Please confirm your account email'),
                  title: Text(statusCode),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text("Login"),
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            UIData.LOGIN, (Route<dynamic> route) => false);
                      },
                    )
                  ],
                );
              });
        } else {
          setState(() {
            _signUp = false;
          });
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text("Signup failed. Please try again ."),
                );
              });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đăng kí người dùng mới")),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
          inAsyncCall: _signUp,
          child: Center(
            child: signUpBody(context),
          )),
    );
  }

  signUpBody(context) => SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[loginHeader(), signUpFields(context)],
        ),
      );

  loginHeader() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
              height: 150.0,
              padding: EdgeInsets.all(20.0),
              alignment: Alignment.center,
              child: Image.asset('assets/images/logo.png',
                  height: 150.0, width: double.infinity, fit: BoxFit.cover)),
          SizedBox(
            height: 15.0,
          ),
          Text(
            "${UIData.APP_NAME} - Ứng dụng mua bán đồ cũ cực chất!",
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red),
          ),
          SizedBox(
            height: 15.0,
          ),
        ],
      );

  Widget signUpFields(context) {
    var lang = S.of(context);
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
              child: TextFormField(
                controller: _username,
                autofocus: true,
                onFieldSubmitted: (term) {
                  FocusScope.of(context).requestFocus(passwordFocus);
                },
                maxLines: 1,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: lang.enter_your_name,
                  labelText: lang.name,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return lang.please_enter_name;
                  }
                  return null;
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
              child: TextFormField(
                controller: _email,
                autofocus: true,
                onFieldSubmitted: (term) {
                  FocusScope.of(context).requestFocus(passwordFocus);
                },
                maxLines: 1,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  labelText: "Email",
                ),
                validator: (value) {
                  Pattern pattern =
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                  RegExp regex = new RegExp(pattern);
                  if (!regex.hasMatch(value)) return lang.please_enter_email;
                  return null;
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
              child: TextFormField(
                controller: _password,
                focusNode: passwordFocus,
                onFieldSubmitted: (term) {
                  FocusScope.of(context).requestFocus(confirmPasswordFocus);
                },
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
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
              child: TextFormField(
                controller: _confirmPassword,
                focusNode: confirmPasswordFocus,
                maxLines: 1,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: lang.confirm_your_password,
                  labelText: lang.repeat_password,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return lang.confirm_your_password;
                  } else if (value != _password.text) {
                    return lang.password_incorrect;
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              width: double.infinity,
              child: RaisedButton(
                padding: EdgeInsets.all(10.0),
//                shape: StadiumBorder(),
                child: Text(
                  lang.sign_up,
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.red,
                onPressed: () {
                  _submit();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
