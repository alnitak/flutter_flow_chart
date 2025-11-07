import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/dashboard.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';
import 'package:flutter_flow_chart/src/ui/draw_arrow.dart';
import 'package:flutter_flow_chart/src/ui/handler_widget.dart';

/// Draw handlers over the element
class ElementHandlers<T> extends StatelessWidget {
  ///
  const ElementHandlers({
    required this.dashboard,
    required this.element,
    required this.handlerSize,
    required this.child,
    required this.onHandlerPressed,
    required this.onHandlerSecondaryTapped,
    required this.onHandlerLongPressed,
    required this.onHandlerSecondaryLongTapped,
    super.key,
  });

  ///
  final Dashboard<T> dashboard;

  ///
  final FlowElement<T> element;

  ///
  final Widget child;

  ///
  final double handlerSize;

  ///
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement<T> element,
  )? onHandlerPressed;

  ///
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement<T> element,
  )? onHandlerLongPressed;

  ///
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement<T> element,
  )? onHandlerSecondaryTapped;

  ///
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement<T> element,
  )? onHandlerSecondaryLongTapped;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: element.size.width + handlerSize,
      height: element.size.height + handlerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          for (int i = 0; i < element.handlers.length; i++)
            _ElementHandler(
              element: element,
              handler: element.handlers[i],
              dashboard: dashboard,
              handlerSize: handlerSize,
              onHandlerPressed: onHandlerPressed,
              onHandlerSecondaryTapped: onHandlerSecondaryTapped,
              onHandlerLongPressed: onHandlerLongPressed,
              onHandlerSecondaryLongTapped: onHandlerSecondaryLongTapped,
            ),
        ],
      ),
    );
  }
}

class _ElementHandler<T> extends StatelessWidget {
  const _ElementHandler({
    required this.element,
    required this.handler,
    required this.dashboard,
    required this.handlerSize,
    required this.onHandlerPressed,
    required this.onHandlerSecondaryTapped,
    required this.onHandlerLongPressed,
    required this.onHandlerSecondaryLongTapped,
  });
  final FlowElement<T> element;
  final Handler handler;
  final Dashboard<T> dashboard;
  final double handlerSize;

  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement<T> element,
  )? onHandlerPressed;

  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement<T> element,
  )? onHandlerSecondaryTapped;

  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement<T> element,
  )? onHandlerLongPressed;

  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement<T> element,
  )? onHandlerSecondaryLongTapped;

  @override
  Widget build(BuildContext context) {
    var isDragging = false;

    Alignment alignment;
    switch (handler) {
      case Handler.topCenter:
        alignment = Alignment.topCenter;
      case Handler.bottomCenter:
        alignment = Alignment.bottomCenter;
      case Handler.leftCenter:
        alignment = Alignment.centerLeft;
      case Handler.rightCenter:
        alignment = Alignment.centerRight;
    }

    var tapDown = Offset.zero;
    var secondaryTapDown = Offset.zero;
    return Align(
      alignment: alignment,
      child: DragTarget<Map<dynamic, dynamic>>(
        onWillAcceptWithDetails: (details) {
          DrawingArrow.instance.setParams(
            DrawingArrow.instance.params.copyWith(
              endArrowPosition: alignment,
              style: dashboard.defaultArrowStyle,
            ),
          );
          return element != details.data['srcElement'] as FlowElement<T>;
        },
        onAcceptWithDetails: (details) {
          dashboard.addNextById(
            details.data['srcElement'] as FlowElement<T>,
            element.id,
            DrawingArrow.instance.params.copyWith(
              endArrowPosition: alignment,
            ),
          );
        },
        onLeave: (data) {
          DrawingArrow.instance.setParams(
            DrawingArrow.instance.params.copyWith(
              endArrowPosition: Alignment.center,
              style: dashboard.defaultArrowStyle,
            ),
          );
        },
        builder: (context, candidateData, rejectedData) {
          return Draggable(
            feedback: const SizedBox.shrink(),
            feedbackOffset: dashboard.handlerFeedbackOffset,
            childWhenDragging: HandlerWidget(
              width: handlerSize,
              height: handlerSize,
              backgroundColor: Colors.blue,
            ),
            data: {
              'srcElement': element,
              'alignment': alignment,
            },
            child: GestureDetector(
              onTapDown: (details) =>
                  tapDown = details.globalPosition - dashboard.position,
              onSecondaryTapDown: (details) => secondaryTapDown =
                  details.globalPosition - dashboard.position,
              onTap: () {
                onHandlerPressed?.call(
                  context,
                  tapDown,
                  handler,
                  element,
                );
              },
              onSecondaryTap: () {
                onHandlerSecondaryTapped?.call(
                  context,
                  secondaryTapDown,
                  handler,
                  element,
                );
              },
              onLongPress: () {
                onHandlerLongPressed?.call(
                  context,
                  tapDown,
                  handler,
                  element,
                );
              },
              onSecondaryLongPress: () {
                onHandlerSecondaryLongTapped?.call(
                  context,
                  secondaryTapDown,
                  handler,
                  element,
                );
              },
              child: HandlerWidget(
                width: handlerSize,
                height: handlerSize,
              ),
            ),
            onDragUpdate: (details) {
              if (!isDragging) {
                DrawingArrow.instance.params = ArrowParams(
                  startArrowPosition: alignment,
                  endArrowPosition: Alignment.center,
                );
                DrawingArrow.instance.from =
                    details.globalPosition - dashboard.position;
                isDragging = true;
              }
              DrawingArrow.instance.setTo(
                details.globalPosition -
                    dashboard.position +
                    dashboard.handlerFeedbackOffset,
              );
            },
            onDragEnd: (details) {
              DrawingArrow.instance.reset();
              isDragging = false;
            },
          );
        },
      ),
    );
  }
}
