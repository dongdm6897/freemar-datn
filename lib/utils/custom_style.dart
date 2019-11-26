import 'package:flutter/material.dart';

class CustomTextStyle {
  static TextStyle labelInformation(BuildContext context) {
    return Theme.of(context)
        .textTheme
        .subtitle
        .copyWith(color: Colors.grey.shade600);
  }

  static TextStyle textTitleNormal(BuildContext context) {
    return Theme.of(context).textTheme.title.copyWith(fontSize: 16.0);
  }

  static TextStyle textExplainNormal(BuildContext context) {
    return Theme.of(context)
        .textTheme
        .subtitle
        .copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.normal);
  }

  static TextStyle textExplainEmphasize(BuildContext context) {
    return Theme.of(context)
        .textTheme
        .subtitle
        .copyWith(color: Colors.red.shade300);
  }

  static TextStyle subLabelInformation(BuildContext context) {
    return Theme.of(context)
        .textTheme
        .subtitle
        .copyWith(color: Colors.grey.shade600, fontStyle: FontStyle.italic);
  }

  static TextStyle textPrice(BuildContext context) {
    return Theme.of(context)
        .textTheme
        .title
        .copyWith(fontSize: 20.0, color: Colors.red);
  }

  static TextStyle textTitleEmphasize(BuildContext context) {
    return Theme.of(context)
        .textTheme
        .title
        .copyWith(fontSize: 20.0, color: Colors.red);
  }

  static TextStyle textTitleEmphasizeUnderline(BuildContext context) {
    return Theme.of(context).textTheme.title.copyWith(
        fontSize: 20.0,
        color: Colors.red,
        decoration: TextDecoration.underline);
  }

  static TextStyle textSubtitleDatetime(BuildContext context) {
    return Theme.of(context).textTheme.subtitle.copyWith(
        color: Colors.grey.shade700,
        fontStyle: FontStyle.italic,
        fontSize: 10.0);
  }

  static TextStyle textLink(BuildContext context) {
    return Theme.of(context).textTheme.subtitle.copyWith(
        decoration: TextDecoration.underline, fontStyle: FontStyle.italic);
  }

  static TextStyle textTime(BuildContext context) {
    return Theme.of(context)
        .textTheme
        .subtitle
        .copyWith(fontStyle: FontStyle.italic, color: Colors.grey);
  }
}

class CustomStyle {
  static Color get iconInterest => Colors.grey.shade600;
}
