import 'package:flutter/material.dart';

class ListCell extends StatelessWidget {
  final Widget leading, trailing;
  final String title, subtitle;
  final VoidCallback onTap;

  ListCell({
    this.leading,
    this.trailing,
    this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
//      contentPadding:
//      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      leading: leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      subtitle: Text(subtitle,
          style: Theme.of(context)
              .textTheme
              .subhead
              .copyWith(color: Color(0xFFBCBCBC))),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
