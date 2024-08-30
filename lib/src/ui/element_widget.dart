import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_flow_chart/src/objects/diamond_widget.dart';
import 'package:flutter_flow_chart/src/objects/hexagon_widget.dart';
import 'package:flutter_flow_chart/src/objects/image_widget.dart';
import 'package:flutter_flow_chart/src/objects/oval_widget.dart';
import 'package:flutter_flow_chart/src/objects/parallelogram_widget.dart';
import 'package:flutter_flow_chart/src/objects/rectangle_widget.dart';
import 'package:flutter_flow_chart/src/objects/storage_widget.dart';

import 'element_handlers.dart';
import 'handler_widget.dart';

/// Widget that use [element] properties to display it on the dashboard scene
class ElementWidget extends StatefulWidget {
  ///
  const ElementWidget({
    required this.dashboard,
    required this.element,
    super.key,
    this.onElementPressed,
    this.onElementSecondaryTapped,
    this.onElementLongPressed,
    this.onElementSecondaryLongTapped,
    this.onHandlerPressed,
    this.onHandlerSecondaryTapped,
    this.onHandlerLongPressed,
    this.onHandlerSecondaryLongTapped,
  });

  ///
  final Dashboard dashboard;

  ///
  final FlowElement element;

  ///
  final void Function(BuildContext context, Offset position)? onElementPressed;

  ///
  final void Function(BuildContext context, Offset position)?
      onElementSecondaryTapped;

  ///
  final void Function(BuildContext context, Offset position)?
      onElementLongPressed;

  ///
  final void Function(BuildContext context, Offset position)?
      onElementSecondaryLongTapped;

  ///
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerPressed;

  ///
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerSecondaryTapped;

  ///
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerLongPressed;

  ///
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerSecondaryLongTapped;

  @override
  State<ElementWidget> createState() => _ElementWidgetState();
}

class _ElementWidgetState extends State<ElementWidget> {
  // local widget touch position when start dragging
  Offset delta = Offset.zero;
  late Size elementStartSize;

  @override
  void initState() {
    super.initState();
    widget.element.addListener(_elementChanged);
  }

  @override
  void dispose() {
    widget.element.removeListener(_elementChanged);
    super.dispose();
  }

  void _elementChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget element;

    switch (widget.element.kind) {
      case ElementKind.diamond:
        element = DiamondWidget(element: widget.element);
      case ElementKind.storage:
        element = StorageWidget(element: widget.element);
      case ElementKind.oval:
        element = OvalWidget(element: widget.element);
      case ElementKind.parallelogram:
        element = ParallelogramWidget(element: widget.element);
      case ElementKind.hexagon:
        element = HexagonWidget(element: widget.element);
      case ElementKind.rectangle:
        element = RectangleWidget(element: widget.element);
      case ElementKind.image:
        element = ImageWidget(element: widget.element);
    }

    if (widget.element.isConnectable && widget.element.handlers.isNotEmpty) {
      element = ElementHandlers(
        dashboard: widget.dashboard,
        element: widget.element,
        handlerSize: widget.element.handlerSize,
        onHandlerPressed: widget.onHandlerPressed,
        onHandlerSecondaryTapped: widget.onHandlerSecondaryTapped,
        onHandlerLongPressed: widget.onHandlerLongPressed,
        onHandlerSecondaryLongTapped: widget.onHandlerSecondaryLongTapped,
        child: element,
      );
    } else {
      element = Padding(
        padding: EdgeInsets.all(widget.element.handlerSize / 2),
        child: element,
      );
    }

    if (widget.element.isDraggable) {
      element = _buildDraggableWidget(element);
    }

    var tapLocation = Offset.zero;
    var secondaryTapDownPos = Offset.zero;
    element = GestureDetector(
      onTapDown: (details) => tapLocation = details.globalPosition,
      onSecondaryTapDown: (details) =>
          secondaryTapDownPos = details.globalPosition,
      onTap: () {
        widget.onElementPressed?.call(context, tapLocation);
      },
      onSecondaryTap: () {
        widget.onElementSecondaryTapped?.call(context, secondaryTapDownPos);
      },
      onLongPress: () {
        widget.onElementLongPressed?.call(context, tapLocation);
      },
      onSecondaryLongPress: () {
        widget.onElementSecondaryLongTapped?.call(context, secondaryTapDownPos);
      },
      child: element,
    );

    return Transform.translate(
      offset: widget.element.position,
      child: SizedBox(
        width: widget.element.size.width + widget.element.handlerSize,
        height: widget.element.size.height + widget.element.handlerSize,
        child: Stack(
          children: [
            element,
            if (widget.element.isResizable) _buildResizeHandle(),
            if (widget.element.isDeletable) _buildDeleteHandle(),
          ],
        ),
      ),
    );
  }

  Widget _buildResizeHandle() {
    return Listener(
      onPointerDown: (event) {
        elementStartSize = widget.element.size;
      },
      onPointerMove: (event) {
        elementStartSize += event.localDelta;
        widget.element.changeSize(elementStartSize);
      },
      onPointerUp: (event) {
        // widget.dashboard.setElementResizable(widget.element, false);
      },
      child: const Align(
        alignment: Alignment.bottomRight,
        child: HandlerWidget(
          width: 30,
          height: 30,
          icon: Icon(Icons.compare_arrows),
        ),
      ),
    );
  }

  Widget _buildDeleteHandle() {
    return Listener(
      onPointerUp: (event) {
        widget.dashboard.removeElement(widget.element);
      },
      child: const Align(
        alignment: Alignment.bottomLeft,
        child: HandlerWidget(
          width: 30,
          height: 30,
          icon: Icon(Icons.delete_outline),
        ),
      ),
    );
  }

  Widget _buildDraggableWidget(Widget element) {
    return Listener(
      onPointerDown: (event) {
        delta = event.localPosition;
      },
      child: Draggable<FlowElement>(
        data: widget.element,
        childWhenDragging: const SizedBox.shrink(),
        feedback: Material(
          color: Colors.transparent,
          child: element,
        ),
        child: element,
        onDragUpdate: (details) {
          widget.element.changePosition(
            details.globalPosition - widget.dashboard.position - delta,
          );
        },
        onDragEnd: (details) {
          widget.element
              .changePosition(details.offset - widget.dashboard.position);
        },
      ),
    );
  }
}
