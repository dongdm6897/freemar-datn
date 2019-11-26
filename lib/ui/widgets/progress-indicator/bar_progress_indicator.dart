import 'package:flutter/material.dart'
;
class BarProgressIndicator extends StatefulWidget {
  final int numberOfBars;
  final double fontSize;
  final double barSpacing;
  final Color color;
  final int milliseconds;
  final double beginTweenValue;
  final double endTweenValue;

  BarProgressIndicator({
    this.numberOfBars = 3,
    this.fontSize = 10.0,
    this.color = Colors.black,
    this.barSpacing = 0.0,
    this.milliseconds = 250,
    this.beginTweenValue = 5.0,
    this.endTweenValue = 10.0,
  });

  _BarProgressIndicatorState createState() => _BarProgressIndicatorState(
    numberOfBars: this.numberOfBars,
    fontSize: this.fontSize,
    color: this.color,
    barSpacing: this.barSpacing,
    milliseconds: this.milliseconds,
    beginTweenValue: this.beginTweenValue,
    endTweenValue: this.endTweenValue,
  );
}

class _BarProgressIndicatorState extends State<BarProgressIndicator>
    with TickerProviderStateMixin {
  int numberOfBars;
  int milliseconds;
  double fontSize;
  double barSpacing;
  Color color;
  double beginTweenValue;
  double endTweenValue;
  List<AnimationController> controllers = new List<AnimationController>();
  List<Animation<double>> animations = new List<Animation<double>>();
  List<Widget> _widgets = new List<Widget>();

  _BarProgressIndicatorState({
    this.numberOfBars,
    this.fontSize,
    this.color,
    this.barSpacing,
    this.milliseconds,
    this.beginTweenValue,
    this.endTweenValue,
  });

  initState() {
    super.initState();
    for (int i = 0; i < numberOfBars; i++) {
      _addAnimationControllers();
      _buildAnimations(i);
      _addListOfDots(i);
    }

    controllers[0].forward();
  }

  void _addAnimationControllers() {
    controllers.add(AnimationController(
        duration: Duration(milliseconds: milliseconds), vsync: this));
  }

  void _addListOfDots(int index) {
    _widgets.add(Padding(
      padding: EdgeInsets.only(right: barSpacing),
      child: _AnimatingBar(
        animation: animations[index],
        fontSize: fontSize,
        color: color,
      ),
    ));
  }

  void _buildAnimations(int index) {
    animations.add(
        Tween(begin: widget.beginTweenValue, end: widget.endTweenValue)
            .animate(controllers[index])
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed)
              controllers[index].reverse();
            if (index == numberOfBars - 1 &&
                status == AnimationStatus.dismissed) {
              controllers[0].forward();
            }
            if (animations[index].value > widget.endTweenValue / 2 &&
                index < numberOfBars - 1) {
              controllers[index + 1].forward();
            }
          }));
  }

  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: _widgets,
      ),
    );
  }

  dispose() {
    for (int i = 0; i < numberOfBars; i++) controllers[i].dispose();
    super.dispose();
  }
}

class _AnimatingBar extends AnimatedWidget {
  final Color color;
  final double fontSize;
  _AnimatingBar(
      {Key key, Animation<double> animation, this.color, this.fontSize})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Container(
      height: animation.value,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(2.0),
        color: color,
      ),
      width: 5.0,
    );
  }
}