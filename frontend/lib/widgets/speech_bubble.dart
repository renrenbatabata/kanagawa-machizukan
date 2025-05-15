import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  Bubble({Key? key, required this.text, required this.textStyle})
    : super(key: key);

  final String text;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 32, top: 16, right: 32, bottom: 8),
      // ここにconstつけるとhot reloadで変わらない
      decoration: ShapeDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        shadows: [
          BoxShadow(
            color: Color.fromARGB(164, 241, 115, 19),
            offset: Offset(2, 1),
            blurRadius: 2,
          ),
        ],
        shape: BubbleBorder(),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Text(text, style: textStyle)],
      ),
    );
  }
}

class BubbleBorder extends ShapeBorder {
  final bool usePadding;

  const BubbleBorder({this.usePadding = true});

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      // xは少なくなると左、多くなると右
      // yは少なくなると上に移動する
      ..moveTo(rect.bottomCenter.dx + -15, rect.bottomCenter.dy)
      ..relativeLineTo(15, 16)
      ..relativeLineTo(15, -16)
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)))
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
