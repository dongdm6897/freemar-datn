import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  GoogleSignInButton(
      {@required this.onPressed, this.text = 'Google', Key key})
      : assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      height: 40.0,
      padding: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: RaisedButton(
        onPressed: onPressed,
        color: Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image(
              image: AssetImage("assets/images/social/glogo.png"),
              height: 20.0,
              width: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 14.0, right: 10.0),
              child: Text(
                text,
                style: TextStyle(
                  // default to the application font-style
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}