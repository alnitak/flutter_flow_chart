import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

/// Common widget for the element text
class ElementTextWidget extends StatelessWidget {
  ///
  const ElementTextWidget({
    required this.element,
    super.key,
  });

  ///
  final FlowElement element;

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Text(
        element.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: element.textColor,
          fontSize: element.textSize,
          fontWeight: element.textIsBold ? FontWeight.bold : FontWeight.normal,
          fontFamily: element.fontFamily,
        ),
      ),
    );
  }
}
