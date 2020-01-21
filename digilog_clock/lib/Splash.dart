import 'package:flutter/material.dart';



class Splash extends StatefulWidget {
  final Color color;
  final double size;

  const Splash({Key key, this.color, this.size}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> size;
  Animation<Color> splashColor;


  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: Duration( milliseconds: 950));
    super.initState();

    size = Tween(begin: 10.0, end: widget.size).animate(_controller);
    splashColor = ColorTween(
            begin: widget.color.withOpacity(.4),
            end: widget.color.withOpacity(0))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInSine));
    _controller.addListener(() => setState(() {}));
      _controller.repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: size.value,
        width: size.value,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: splashColor.value),
      ),
    );
  }


}
