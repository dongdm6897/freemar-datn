import 'package:flutter/material.dart';

class GuideAlert extends StatelessWidget {
  final String title, description, buttonText;
  final Image image;

  GuideAlert({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    height: 150,
                    width: double.infinity,
                    child: Image.asset('assets/images/thingstosell.jpg',
                        height: 150.0, fit: BoxFit.fill)),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                        top: 20.0, left: 10.0, right: 10.0, bottom: 5.0),
                    child: Text(this.title,
                        style: Theme.of(context)
                            .textTheme
                            .title
                            .copyWith(color: Colors.red))),
                Container(
                    alignment: Alignment.center,
                    padding:
                        EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                    child: Text(this.description,
                        style: Theme.of(context).textTheme.subtitle)),
                Container(
                  padding: EdgeInsets.all(15.0),
                  alignment: Alignment.center,
                  child: FlatButton(
                    color: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop(true); // To close the dialog
                    },
                    child: Text(
                      this.buttonText,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
