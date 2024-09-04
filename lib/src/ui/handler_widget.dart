import 'package:flutter/material.dart';

/// The arrow tip.
class HandlerWidget extends StatelessWidget {
  ///
  const HandlerWidget({
    required this.width,
    required this.height,
    super.key,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.blue,
    this.icon,
  });

  ///
  final double width;

  ///
  final double height;

  ///
  final Color backgroundColor;

  ///
  final Color borderColor;

  ///
  final Widget? icon;

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
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: FittedBox(child: icon),
      ),
    );
  }
}
