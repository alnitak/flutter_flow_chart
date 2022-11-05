import 'package:flutter/material.dart';

import '../elements/flow_element.dart';
import 'element_text_widget.dart';

/// A kind of element
class RectangleWidget extends StatelessWidget {
  final FlowElement element;

  const RectangleWidget({
    Key? key,
    required this.element,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: element.backgroundColor,
              boxShadow: [
                if (element.elevation > 0.01)
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(element.elevation, element.elevation),
                    blurRadius: element.elevation * 1.3,
                  ),
              ],
              border: Border.all(
                color: element.borderColor,
                width: element.borderThickness,
              ),
            ),
          ),
          ElementTextWidget(element: element),
        ],
      ),
    );
  }
}
