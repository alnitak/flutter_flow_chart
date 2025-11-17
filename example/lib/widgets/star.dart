import 'dart:math' as math;

import 'package:flutter/material.dart';

/// StarWidget: a reusable widget that draws a star shape with elevation,
/// box shadow and centered text inside. Background (app scaffold) is white.
///
/// Usage:
///   StarWidget(
///     size: 200,
///     fillColor: Colors.amber,
///     text: 'Hello',
// ignore: lines_longer_than_80_chars
///     textStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
///     elevation: 8,
///     shadowColor: Colors.black54,
///   )

class StarWidget extends StatelessWidget {
  ///
  const StarWidget({
    super.key,
    this.size = 150,
    this.fillColor = Colors.amber,
    this.text = '',
    this.textStyle,
    this.elevation = 6.0,
    this.shadowColor = Colors.black45,
  });

  ///
  final double size;

  ///
  final Color fillColor;

  ///
  final String text;

  ///
  final TextStyle? textStyle;

  ///
  final double elevation;

  ///
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    // PhysicalShape gives us a clip by a Path and a real elevation shadow.
    return SizedBox(
      width: size,
      height: size,
      child: PhysicalShape(
        clipper: _StarClipper(),
        color: fillColor,
        elevation: elevation,
        shadowColor: shadowColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: textStyle ??
                  TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.14,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom clipper that creates a star shaped Path.
class _StarClipper extends CustomClipper<Path> {
  _StarClipper();

  final int points = 5;
  final double innerRatio = 0.5;

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final outerRadius = (w < h ? w : h) / 2;
    final innerRadius = outerRadius * innerRatio;

    var angle = -math.pi / 2; // start at top
    final step = math.pi / points;

    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerRadius : innerRadius;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle += step;
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
