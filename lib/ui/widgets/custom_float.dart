import 'package:flutter/material.dart';

class CustomFloat extends StatelessWidget {
  final IconData icon;
  final Widget builder;
  final VoidCallback qrCallback;
  final isMini;

  CustomFloat({this.icon, this.builder, this.qrCallback, this.isMini = false});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      clipBehavior: Clip.antiAlias,
      mini: isMini,
      onPressed: qrCallback,
      child: Stack(
        children: <Widget>[
          Icon(icon),
        ],
      ),
    );
  }
}
