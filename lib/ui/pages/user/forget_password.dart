import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/login_bloc.dart';

class ForgetPassword extends StatefulWidget {
  @override
  ForgetPasswordState createState() {
    return ForgetPasswordState();
  }
}

class ForgetPasswordState extends State<ForgetPassword> {
  LoginBloc loginBloc = LoginBloc();
  final _formKey = GlobalKey<FormState>();
  FocusNode confirmPasswordFocus;
  TextEditingController _email, _password, _confirmPassword;

  @override
  void initState() {
    super.initState();
    confirmPasswordFocus = FocusNode();
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    confirmPasswordFocus.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Welcome to Flutter",
        home: Material(
            child: Container(
                padding: const EdgeInsets.all(30.0),
                color: Colors.white,
                child: Container(
                  child: Center(
                      child: Form(
                    key: _formKey,
                    child: Column(children: [
                      FlutterLogo(
                        colors: Colors.red,
                        size: 80.0,
                      ),
                      Padding(padding: EdgeInsets.only(top: 50.0)),
                      TextFormField(
                        controller: _email,
                        decoration: InputDecoration(
                          labelText: "Enter Email",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
//                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          //fillColor: Colors.green
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Email cannot be empty";
                          } else if (!value.contains('@')) {
                            return "Wrong Email";
                          }
                        },
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontFamily: "Robonto",
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 20.0)),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "New Password",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
//                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(),
                          ),
                          //fillColor: Colors.green
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Password cannot be empty";
                          }
                        },
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontFamily: "Robonto",
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 20.0)),
                      TextFormField(
                        controller: _confirmPassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Confirm password",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
//                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(),
                          ),
                          //fillColor: Colors.green
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Confirm your password';
                          } else if (value != _password.text) {
                            return 'Those password didnt match.Try again';
                          }
                        },
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontFamily: "Robonto",
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 30.0)),
                      FlatButton(
                        color: Colors.red,
                        child: Text(
                          "Next",
                          style: TextStyle(color: Colors.white),
                        ),
                        textColor: Colors.white,
                        onPressed: () {},
                      )
                    ]),
                  )),
                ))));
  }
}
