import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_flow_chart/src/dashboard.dart';
import 'package:flutter_flow_chart/src/ui/draw_arrow.dart';
import 'package:flutter_flow_chart/src/ui/element_widget.dart';
import 'package:flutter_flow_chart/src/ui/grid_background.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';

/// Main flow chart Widget.
/// It displays the background grid, all the elements and connection lines
class FlowChart extends StatefulWidget {
  /// callback for tap on dashboard
  final Function(BuildContext context, Offset position)? onDashboardTapped;

  /// callback for long tap on dashboard
  final Function(BuildContext context, Offset position)? onDashboardLongTapped;

  /// callback for mouse right click on dashboard
  final Function(BuildContext context, Offset postision)?
      onDashboardSecondaryTapped;

  /// callback for mouse right click long press on dashboard
  final Function(BuildContext context, Offset position)?
      onDashboardSecondaryLongTapped;

  /// callback for element pressed
  final Function(BuildContext context, Offset position, FlowElement element)?
      onElementPressed;

  /// callback for mouse rightclick event on an element
  final Function(BuildContext context, Offset position, FlowElement element)?
      onElementSecondaryTapped;

  /// callback for element long pressed
  final Function(BuildContext context, Offset position, FlowElement element)?
      onElementLongPressed;

  /// callback for right click long press event on an element
  final Function(BuildContext context, Offset position, FlowElement element)?
      onElementSecondaryLongTapped;

  /// callback for handler pressed
  final Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerPressed;

  /// callback for handler right click event
  final Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerSecondaryTapped;

  /// callback for handler right click long press event
  final Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerSecondaryLongTapped;

  /// callback for handler long pressed
  final Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerLongPressed;

  /// callback for line tapped
  final void Function(
    BuildContext context,
    Offset clickPosition,
    FlowElement srcElement,
    FlowElement destElement,
  )? onLineTapped;

  /// callback for line long pressed
  final void Function(
    BuildContext context,
    Offset clickPosition,
    FlowElement srcElement,
    FlowElement destElement,
  )? onLineLongPressed;

  /// callback for line right click event
  final void Function(
    BuildContext context,
    Offset clickPosition,
    FlowElement srcElement,
    FlowElement destElement,
  )? onLineSecondaryTapped;

  /// callback for line right click long press event
  final void Function(
    BuildContext context,
    Offset clickPosition,
    FlowElement srcElement,
    FlowElement destElement,
  )? onLineSecondaryLongTapped;

  /// main dashboard to use
  final Dashboard dashboard;

  final void Function(double scale)? onScaleUpdate;

  const FlowChart({
    super.key,
    this.onElementPressed,
    this.onElementSecondaryTapped,
    this.onElementLongPressed,
    this.onElementSecondaryLongTapped,
    this.onDashboardTapped,
    this.onDashboardSecondaryTapped,
    this.onDashboardLongTapped,
    this.onDashboardSecondaryLongTapped,
    this.onHandlerPressed,
    this.onHandlerSecondaryTapped,
    this.onHandlerLongPressed,
    this.onHandlerSecondaryLongTapped,
    this.onLineTapped,
    this.onLineLongPressed,
    this.onLineSecondaryTapped,
    this.onLineSecondaryLongTapped,
    this.onScaleUpdate,
    required this.dashboard,
  });

  @override
  State<FlowChart> createState() => _FlowChartState();
}

class _FlowChartState extends State<FlowChart> {
  @override
  void initState() {
    super.initState();
    widget.dashboard.addListener(_elementChanged);
    if (widget.onScaleUpdate != null) {
      widget.dashboard.gridBackgroundParams.addOnScaleUpdateListener(
        widget.onScaleUpdate!,
      );
    }
  }

  @override
  void dispose() {
    widget.dashboard.removeListener(_elementChanged);
    if (widget.onScaleUpdate != null) {
      widget.dashboard.gridBackgroundParams.removeOnScaleUpdateListener(
        widget.onScaleUpdate!,
      );
    }
    super.dispose();
  }

  _elementChanged() {
    if (mounted) setState(() {});
  }

  double _oldScaleUpdateDelta = 0;

  @override
  Widget build(BuildContext context) {
    /// get dashboard position after first frame is drawn
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        final object = (context.findRenderObject() as RenderBox);
        final translation = object.getTransformTo(null).getTranslation();
        final Size size = object.semanticBounds.size;
        Offset position = Offset(translation.x, translation.y);

        widget.dashboard.setDashboardSize(size);
        widget.dashboard.setDashboardPosition(position);
      }
    });

    // disabling default browser context menu on web
    if (kIsWeb) BrowserContextMenu.disableContextMenu();

    GlobalKey gridKey = GlobalKey();
    Offset tapDownPos = Offset.zero;
    Offset secondaryTapDownPos = Offset.zero;
    return ClipRect(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Draw the grid
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) {
                tapDownPos = details.localPosition;
              },
              onSecondaryTapDown: (details) {
                secondaryTapDownPos = details.localPosition;
              },
              onTap: widget.onDashboardTapped == null
                  ? null
                  : () => widget.onDashboardTapped!(
                        gridKey.currentContext!,
                        tapDownPos,
                      ),
              onLongPress: widget.onDashboardLongTapped == null
                  ? null
                  : () => widget.onDashboardLongTapped!(
                        gridKey.currentContext!,
                        tapDownPos,
                      ),
              onSecondaryTap: () {
                if (widget.onDashboardSecondaryTapped != null) {
                  widget.onDashboardSecondaryTapped!(
                    gridKey.currentContext!,
                    secondaryTapDownPos,
                  );
                }
              },
              onSecondaryLongPress: () {
                if (widget.onDashboardSecondaryLongTapped != null) {
                  widget.onDashboardSecondaryLongTapped!(
                    gridKey.currentContext!,
                    secondaryTapDownPos,
                  );
                }
              },
              onScaleUpdate: (details) {
                if (details.scale != 1) {
                  widget.dashboard.setZoomFactor(
                    details.scale + _oldScaleUpdateDelta,
                    focalPoint: details.focalPoint,
                  );
                }

                for (int i = 0; i < widget.dashboard.elements.length; i++) {
                  widget.dashboard.elements[i].position +=
                      details.focalPointDelta;
                }
                widget.dashboard.gridBackgroundParams.offset =
                    details.focalPointDelta;
                setState(() {});
              },
              onScaleEnd: (details) {
                _oldScaleUpdateDelta = widget.dashboard.zoomFactor - 1;
              },
              child: GridBackground(
                key: gridKey,
                params: widget.dashboard.gridBackgroundParams,
              ),
            ),
          ),
          // Draw elements
          for (int i = 0; i < widget.dashboard.elements.length; i++)
            ElementWidget(
              key: UniqueKey(),
              dashboard: widget.dashboard,
              element: widget.dashboard.elements.elementAt(i),
              onElementPressed: widget.onElementPressed == null
                  ? null
                  : (context, position) => widget.onElementPressed!(
                        context,
                        position,
                        widget.dashboard.elements.elementAt(i),
                      ),
              onElementSecondaryTapped: widget.onElementSecondaryTapped == null
                  ? null
                  : (context, position) => widget.onElementSecondaryTapped!(
                        context,
                        position,
                        widget.dashboard.elements.elementAt(i),
                      ),
              onElementLongPressed: widget.onElementLongPressed == null
                  ? null
                  : (context, position) => widget.onElementLongPressed!(
                        context,
                        position,
                        widget.dashboard.elements.elementAt(i),
                      ),
              onElementSecondaryLongTapped:
                  widget.onElementSecondaryLongTapped == null
                      ? null
                      : (context, position) =>
                          widget.onElementSecondaryLongTapped!(
                            context,
                            position,
                            widget.dashboard.elements.elementAt(i),
                          ),
              onHandlerPressed: widget.onHandlerPressed == null
                  ? null
                  : (context, position, handler, element) => widget
                      .onHandlerPressed!(context, position, handler, element),
              onHandlerSecondaryTapped: widget.onHandlerSecondaryTapped == null
                  ? null
                  : (context, position, handler, element) =>
                      widget.onHandlerSecondaryTapped!(
                          context, position, handler, element),
              onHandlerLongPressed: widget.onHandlerLongPressed == null
                  ? null
                  : (context, position, handler, element) =>
                      widget.onHandlerLongPressed!(
                          context, position, handler, element),
              onHandlerSecondaryLongTapped:
                  widget.onHandlerSecondaryLongTapped == null
                      ? null
                      : (context, position, handler, element) =>
                          widget.onHandlerSecondaryLongTapped!(
                              context, position, handler, element),
            ),
          // Draw arrows
          for (int i = 0; i < widget.dashboard.elements.length; i++)
            for (int n = 0; n < widget.dashboard.elements[i].next.length; n++)
              DrawArrow(
                key: UniqueKey(),
                srcElement: widget.dashboard.elements[i],
                destElement: widget
                    .dashboard.elements[widget.dashboard.findElementIndexById(
                  widget.dashboard.elements[i].next[n].destElementId,
                )],
                arrowParams: widget.dashboard.elements[i].next[n].arrowParams,
                onTap: widget.onLineTapped,
                onLongPress: widget.onLineLongPressed,
                onSecondaryTap: widget.onLineSecondaryTapped,
                onSecondaryLongPress: widget.onLineSecondaryLongTapped,
              ),
          // user drawing when connecting elements
          const DrawingArrowWidget(),
        ],
      ),
    );
  }
}

/// Widget to draw interactive connection when the user tap on handlers
class DrawingArrowWidget extends StatefulWidget {
  const DrawingArrowWidget({super.key});

  @override
  State<DrawingArrowWidget> createState() => _DrawingArrowWidgetState();
}

class _DrawingArrowWidgetState extends State<DrawingArrowWidget> {
  @override
  void initState() {
    super.initState();
    DrawingArrow.instance.addListener(_arrowChanged);
  }

  @override
  void dispose() {
    DrawingArrow.instance.removeListener(_arrowChanged);
    super.dispose();
  }

  _arrowChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (DrawingArrow.instance.isZero()) return const SizedBox.shrink();
    return CustomPaint(
      painter: ArrowPainter(
        params: DrawingArrow.instance.params,
        from: DrawingArrow.instance.from,
        to: DrawingArrow.instance.to,
      ),
    );
  }
}
