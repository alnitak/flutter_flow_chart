import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

/// Widget that use [element] properties to display it on the dashboard scene
class SegmentHandler extends StatefulWidget {
  final Pivot pivot;
  final Dashboard dashboard;
  final void Function(BuildContext context, Pivot position)? onPivotPressed;
  final void Function(BuildContext context, Pivot position)?
      onPivotSecondaryPressed;

  const SegmentHandler({
    super.key,
    required this.pivot,
    required this.dashboard,
    this.onPivotPressed,
    this.onPivotSecondaryPressed,
  });

  @override
  State<SegmentHandler> createState() => _SegmentHandlerState();
}

class _SegmentHandlerState extends State<SegmentHandler> {
  Offset delta = Offset.zero;

  @override
  void initState() {
    super.initState();

    widget.pivot.addListener(_update);
  }

  @override
  void dispose() {
    widget.pivot.removeListener(_update);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset:
          widget.pivot.pivot - const Offset(5, 5) * widget.dashboard.zoomFactor,
      transformHitTests: true,
      child: Listener(
        onPointerDown: (evt) {
          delta = evt.delta;
        },
        child: Draggable(
          feedback: const SizedBox(),
          onDragUpdate: (details) {
            widget.pivot.pivot =
                details.globalPosition - widget.dashboard.position - delta;
          },
          onDragEnd: (details) {
            widget.pivot.pivot = details.offset - widget.dashboard.position;
          },
          child: GestureDetector(
            onTap: () {
              widget.onPivotPressed?.call(context, widget.pivot);
            },
            onSecondaryTap: () {
              widget.onPivotSecondaryPressed?.call(context, widget.pivot);
            },
            child: CircleAvatar(
              radius: widget.dashboard.zoomFactor * 5,
              foregroundColor: Colors.black,
              backgroundColor: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  _update() {
    setState(() {});
  }
}

class Pivot extends ChangeNotifier {
  Offset _pivot;

  Pivot(Offset pivot) : _pivot = pivot;

  Pivot.fromMap(Map map)
      : _pivot = Offset(
          map['pivot.dx'],
          map['pivot.dy'],
        );

  Offset get pivot => _pivot;

  set pivot(Offset value) {
    _pivot = value;
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pivot.dx': _pivot.dx,
      'pivot.dy': _pivot.dy,
    };
  }

  void setScale(scale, focalPoint, factor) {
    pivot = ((pivot - focalPoint) / scale) * factor + focalPoint;
  }

  @override
  bool operator ==(Object other) => other is Pivot && other._pivot == _pivot;

  @override
  int get hashCode => _pivot.hashCode;
}
