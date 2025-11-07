import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';
import 'package:flutter_flow_chart/src/objects/element_text_widget.dart';

/// A kind of element
class DiamondWidget extends StatelessWidget {
  ///
  const DiamondWidget({
    required this.element,
    super.key,
  });

  ///
  final FlowElement<dynamic> element;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: Stack(
        children: [
          CustomPaint(
            size: element.size,
            painter: _DiamondPainter(
              element: element,
            ),
          ),
          ElementTextWidget(element: element),
        ],
      ),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  _DiamondPainter({
    required this.element,
  });
  final FlowElement<dynamic> element;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();

    paint
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.fill
      ..color = element.backgroundColor;

    path
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();

    if (element.elevation > 0.01) {
      canvas.drawShadow(
        path.shift(Offset(element.elevation, element.elevation)),
        Colors.black,
        element.elevation,
        true,
      );
    }
    canvas.drawPath(path, paint);

    paint
      ..strokeWidth = element.borderThickness
      ..color = element.borderColor
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
