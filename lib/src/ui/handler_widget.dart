import 'package:flutter/material.dart';

class HandlerWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final Widget? icon;

  const HandlerWidget({
    super.key,
    required this.width,
    required this.height,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.blue,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(
          Radius.circular(width),
        ),
        border: Border.all(
          width: 2,
          color: borderColor,
          style: BorderStyle.solid,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: FittedBox(child: icon),
      ),
    );
  }
}
