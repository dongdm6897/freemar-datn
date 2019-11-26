// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

const double _kOffset =
    40.0; // distance to bottom of banner, at a 45 degree angle inwards
const double _kHeight = 12.0; // height of banner
final Rect _kRect =
    Rect.fromLTWH(-_kOffset, _kOffset - _kHeight, _kOffset * 2.0, _kHeight);

const Color _kColor = Color(0xA0B71C1C);
const TextStyle _kTextStyle = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: _kHeight * 0.85,
    fontWeight: FontWeight.w900,
    height: 1.0);

class BannerPainterCustomize extends BannerPainter {
  BannerPainterCustomize({
    @required this.message,
    @required this.textDirection,
    @required this.location,
    @required this.layoutDirection,
    this.color = _kColor,
    this.textStyle = _kTextStyle,
  }) : super(
            message: message,
            textDirection: textDirection,
            location: location,
            layoutDirection: layoutDirection);

  /// The message to show in the banner.
  final String message;

  /// The directionality of the text.
  ///
  /// This value is used to disambiguate how to render bidirectional text. For
  /// example, if the message is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// See also [layoutDirection], which controls the interpretation of values in
  /// [location].
  final TextDirection textDirection;

  /// Where to show the banner (e.g., the upper right corner).
  final BannerLocation location;

  /// The directionality of the layout.
  ///
  /// This value is used to interpret the [location] of the banner.
  ///
  /// See also [textDirection], which controls the reading direction of the
  /// [message].
  final TextDirection layoutDirection;

  /// The color to paint behind the [message].
  ///
  /// Defaults to a dark red.
  final Color color;

  /// The text style to use for the [message].
  ///
  /// Defaults to bold, white text.
  final TextStyle textStyle;

  static const BoxShadow _shadow = BoxShadow(
    color: Color(0x7F000000),
    blurRadius: 6.0,
  );

  bool _prepared = false;
  TextPainter _textPainter;
  Paint _paintShadow;
  Paint _paintBanner;

  void _prepare() {
    _paintShadow = _shadow.toPaint();
    _paintBanner = Paint()..color = color;
    _textPainter = TextPainter(
      text: TextSpan(style: textStyle, text: message),
      textAlign: TextAlign.center,
      textDirection: textDirection,
    );
    _prepared = true;
  }

  double _translationX(double width) {
    assert(location != null);
    assert(layoutDirection != null);

    return 0.0;
  }

  double _translationY(double height) {
    assert(location != null);
    return 0.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.lineTo(0, _kOffset + 10.0);
    path.lineTo(_kOffset + 10.0, 0);
    path.close();

    if (!_prepared) _prepare();
    canvas
      ..translate(_translationX(size.width), _translationY(size.height))
      ..rotate(_rotation)
      ..drawPath(path, _paintShadow)
      ..drawPath(path, _paintBanner);
    const double width = _kOffset * 2.0;
    _textPainter.layout(minWidth: width, maxWidth: width);
    if (location == BannerLocation.topStart ||
        location == BannerLocation.topEnd) {
      _textPainter.paint(
          canvas..rotate(-math.pi / 4),
          _kRect.topLeft +
              Offset(0.0, (_kRect.height - _textPainter.height * 2)));
    } else {
      _textPainter.paint(
          canvas..rotate(3 * math.pi / 4 + math.pi * 2),
          _kRect.topLeft +
              Offset(0.0, (_kRect.height - _textPainter.height * 5.5)));
    }
  }

  double get _rotation {
    assert(location != null);
    assert(layoutDirection != null);
    switch (location) {
      case BannerLocation.bottomStart:
        return -math.pi / 2;
      case BannerLocation.topEnd:
        return math.pi / 2;
      case BannerLocation.bottomEnd:
        return math.pi;
      case BannerLocation.topStart:
        return 0;
    }

    return null;
  }
}

/// Displays a diagonal message above the corner of another widget.
///
/// Useful for showing the execution mode of an app (e.g., that asserts are
/// enabled.)
///
/// See also:
///
///  * [CheckedModeBanner], which the [WidgetsApp] widget includes by default in
///    debug mode, to show a banner that says "DEBUG".
class BannerCustomize extends Banner {
  /// Creates a banner.
  ///
  /// The [message] and [location] arguments must not be null.
  const BannerCustomize({
    Key key,
    this.child,
    @required this.message,
    this.textDirection,
    @required this.location,
    this.layoutDirection,
    this.color = _kColor,
    this.textStyle = _kTextStyle,
  })  : assert(message != null),
        assert(location != null),
        assert(color != null),
        assert(textStyle != null),
        super(
          message: message,
          textDirection: textDirection,
          location: location,
          layoutDirection: layoutDirection,
        );

  /// The widget to show behind the banner.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// The message to show in the banner.
  final String message;

  /// The directionality of the text.
  ///
  /// This is used to disambiguate how to render bidirectional text. For
  /// example, if the message is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// Defaults to the ambient [Directionality], if any.
  ///
  /// See also [layoutDirection], which controls the interpretation of the
  /// [location].
  final TextDirection textDirection;

  /// Where to show the banner (e.g., the upper right corner).
  final BannerLocation location;

  /// The directionality of the layout.
  ///
  /// This is used to resolve the [location] values.
  ///
  /// Defaults to the ambient [Directionality], if any.
  ///
  /// See also [textDirection], which controls the reading direction of the
  /// [message].
  final TextDirection layoutDirection;

  /// The color of the banner.
  final Color color;

  /// The style of the text shown on the banner.
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    assert((textDirection != null && layoutDirection != null) ||
        debugCheckHasDirectionality(context));
    return CustomPaint(
      painter: BannerPainterCustomize(
        message: message,
        textDirection: textDirection ?? Directionality.of(context),
        location: location,
        layoutDirection: layoutDirection ?? Directionality.of(context),
        color: color,
        textStyle: textStyle,
      ),
      child: child,
    );
  }
}

/// Displays a [Banner] saying "DEBUG" when running in checked mode.
/// [MaterialApp] builds one of these by default.
/// Does nothing in release mode.
