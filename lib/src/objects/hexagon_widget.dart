import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';
import 'package:flutter_flow_chart/src/objects/element_text_widget.dart';

/// A kind of element
class HexagonWidget extends StatelessWidget {
  ///
  const HexagonWidget({
    required this.element,
    super.key,
  });

  ///
  final FlowElement element;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: Stack(
        children: [
          CustomPaint(
            size: element.size,
            painter: _HexagonPainter(
              element: element,
            ),
          ),
          ElementTextWidget(element: element),
        ],
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  _HexagonPainter({
    required this.element,
  });
  final FlowElement element;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();

    paint..style = PaintingStyle.fill
    ..color = element.backgroundColor;

    path..moveTo(0, size.height / 2)
    ..lineTo(size.width / 4, size.height)
    ..lineTo(size.width * 3 / 4, size.height)
    ..lineTo(size.width, size.height / 2)
    ..lineTo(size.width * 3 / 4, 0)
    ..lineTo(size.width / 4, 0)
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

    paint..strokeWidth = element.borderThickness
    ..color = element.borderColor
    ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
