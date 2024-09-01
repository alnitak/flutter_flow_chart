import 'package:auto_size_text/auto_size_text.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

/// Common widget for the element text
class ElementTextWidget extends StatefulWidget {
  ///
  const ElementTextWidget({
    required this.element,
    super.key,
  });

  ///
  final FlowElement element;

  @override
  State<ElementTextWidget> createState() => _ElementTextWidgetState();
}

class _ElementTextWidgetState extends State<ElementTextWidget> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller
      ..text = widget.element.text
      ..addListener(() => widget.element.text = _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: widget.element.textColor,
      fontSize: widget.element.textSize,
      fontWeight:
          widget.element.textIsBold ? FontWeight.bold : FontWeight.normal,
      fontFamily: widget.element.fontFamily,
    );

    Widget textWidget;
    if (widget.element.isAutoSizeText) {
      textWidget = widget.element.isEditingText
          ? AutoSizeTextField(
              controller: _controller,
              autofocus: true,
              onTapOutside: (event) => dismissTextEditor(),
              // FIXME: waiting for https://github.com/lzhuor/auto_size_text_field/pull/36
              // onFieldSubmitted: dismissTextEditor,
              textAlign: TextAlign.center,
              style: textStyle,
            )
          : AutoSizeText(
              widget.element.text,
              minFontSize: 8,
              textAlign: TextAlign.center,
              style: textStyle,
            );
    } else {
      textWidget = widget.element.isEditingText
          ? TextFormField(
              controller: _controller,
              autofocus: true,
              onTapOutside: (event) => dismissTextEditor(),
              textAlign: TextAlign.center,
              style: textStyle,
            )
          : Text(
              widget.element.text,
              textAlign: TextAlign.center,
              style: textStyle,
            );
    }

    return Align(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: textWidget,
      ),
    );
  }

  void dismissTextEditor([String? text]) {
    if (text != null) widget.element.text = text;
    setState(() => widget.element.isEditingText = false);
  }
}
