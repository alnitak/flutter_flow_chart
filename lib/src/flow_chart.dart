// ignore: directives_ordering
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flow_chart/src/dashboard.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';
import 'package:flutter_flow_chart/src/ui/draw_arrow.dart';
import 'package:flutter_flow_chart/src/ui/element_widget.dart';
import 'package:flutter_flow_chart/src/ui/grid_background.dart';
import 'package:flutter_flow_chart/src/ui/segment_handler.dart';

/// Main flow chart Widget.
/// It displays the background grid, all the elements and connection lines
class FlowChart extends StatefulWidget {
  ///
  const FlowChart({
    required this.dashboard,
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
    this.onPivotPressed,
    this.onPivotSecondaryPressed,
    this.onScaleUpdate,
    this.onNewConnection,
  });

  /// callback for tap on dashboard
  final void Function(BuildContext context, Offset position)? onDashboardTapped;

  /// callback for long tap on dashboard
  final void Function(BuildContext context, Offset position)?
      onDashboardLongTapped;

  /// callback for mouse right click on dashboard
  final void Function(BuildContext context, Offset postision)?
      onDashboardSecondaryTapped;

  /// callback for mouse right click long press on dashboard
  final void Function(BuildContext context, Offset position)?
      onDashboardSecondaryLongTapped;

  /// callback for element pressed
  final void Function(
    BuildContext context,
    Offset position,
    FlowElement element,
  )? onElementPressed;

  /// callback for mouse right click event on an element
  final void Function(
    BuildContext context,
    Offset position,
    FlowElement element,
  )? onElementSecondaryTapped;

  /// callback for element long pressed
  final void Function(
    BuildContext context,
    Offset position,
    FlowElement element,
  )? onElementLongPressed;

  /// callback for right click long press event on an element
  final void Function(
    BuildContext context,
    Offset position,
    FlowElement element,
  )? onElementSecondaryLongTapped;

  /// callback for onclick event of pivot
  final void Function(BuildContext context, Pivot pivot)? onPivotPressed;

  /// callback for secondary press event of pivot
  final void Function(BuildContext context, Pivot pivot)?
      onPivotSecondaryPressed;

  /// callback for handler pressed
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerPressed;

  /// callback for handler right click event
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerSecondaryTapped;

  /// callback for handler right click long press event
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerSecondaryLongTapped;

  /// callback for handler long pressed
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerLongPressed;

  /// callback when adding a new connection
  final ConnectionListener? onNewConnection;

  /// main dashboard to use
  final Dashboard dashboard;

  /// Trigger for the scale change
  final void Function(double scale)? onScaleUpdate;

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
    if (widget.onNewConnection != null) {
      widget.dashboard.addConnectionListener(widget.onNewConnection!);
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

  void _elementChanged() {
    if (mounted) setState(() {});
  }

  double _oldScaleUpdateDelta = 0;

  @override
  Widget build(BuildContext context) {
    /// get dashboard position after first frame is drawn
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        final object = context.findRenderObject() as RenderBox?;
        if (object != null) {
          final translation = object.getTransformTo(null).getTranslation();
          final size = object.semanticBounds.size;
          final position = Offset(translation.x, translation.y);

          widget.dashboard.setDashboardSize(size);
          widget.dashboard.setDashboardPosition(position);
        }
      }
    });

    // disabling default browser context menu on web
    if (kIsWeb) BrowserContextMenu.disableContextMenu();

    final gridKey = GlobalKey();
    var tapDownPos = Offset.zero;
    var secondaryTapDownPos = Offset.zero;
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
                widget.onDashboardSecondaryTapped?.call(
                  gridKey.currentContext!,
                  secondaryTapDownPos,
                );
              },
              onSecondaryLongPress: () {
                widget.onDashboardSecondaryLongTapped?.call(
                  gridKey.currentContext!,
                  secondaryTapDownPos,
                );
              },
              onScaleUpdate: (details) {
                if (details.scale != 1) {
                  widget.dashboard.setZoomFactor(
                    details.scale + _oldScaleUpdateDelta,
                    focalPoint: details.focalPoint,
                  );
                }

                widget.dashboard.setDashboardPosition(
                  widget.dashboard.position + details.focalPointDelta,
                );
                for (var i = 0; i < widget.dashboard.elements.length; i++) {
                  widget.dashboard.elements[i].position +=
                      details.focalPointDelta;
                  for (final conn in widget.dashboard.elements[i].next) {
                    for (final pivot in conn.pivots) {
                      pivot.pivot += details.focalPointDelta;
                    }
                  }
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
              key: ValueKey(widget.dashboard.elements.elementAt(i).id),
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
                        context,
                        position,
                        handler,
                        element,
                      ),
              onHandlerLongPressed: widget.onHandlerLongPressed == null
                  ? null
                  : (context, position, handler, element) =>
                      widget.onHandlerLongPressed!(
                        context,
                        position,
                        handler,
                        element,
                      ),
              onHandlerSecondaryLongTapped:
                  widget.onHandlerSecondaryLongTapped == null
                      ? null
                      : (context, position, handler, element) =>
                          widget.onHandlerSecondaryLongTapped!(
                            context,
                            position,
                            handler,
                            element,
                          ),
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
                pivots: widget.dashboard.elements[i].next[n].pivots,
              ),
          // drawing segment handlers
          for (int i = 0; i < widget.dashboard.elements.length; i++)
            for (int n = 0; n < widget.dashboard.elements[i].next.length; n++)
              if (widget.dashboard.elements[i].next[n].arrowParams.style ==
                  ArrowStyle.segmented)
                for (int j = 0;
                    j < widget.dashboard.elements[i].next[n].pivots.length;
                    j++)
                  SegmentHandler(
                    key: UniqueKey(),
                    pivot: widget.dashboard.elements[i].next[n].pivots[j],
                    dashboard: widget.dashboard,
                    onPivotPressed: widget.onPivotPressed,
                    onPivotSecondaryPressed: widget.onPivotSecondaryPressed,
                  ),
          // user drawing when connecting elements
          DrawingArrowWidget(style: widget.dashboard.defaultArrowStyle),
        ],
      ),
    );
  }
}

/// Widget to draw interactive connection when the user tap on handlers
class DrawingArrowWidget extends StatefulWidget {
  ///
  const DrawingArrowWidget({required this.style, super.key});

  ///
  final ArrowStyle style;

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

  void _arrowChanged() {
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
