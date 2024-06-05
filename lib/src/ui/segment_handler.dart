import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

/// Widget that use the element properties to display it on the dashboard scene.
class SegmentHandler extends StatefulWidget {
  ///
  const SegmentHandler({
    required this.pivot,
    required this.dashboard,
    super.key,
    this.onPivotPressed,
    this.onPivotSecondaryPressed,
  });

  ///
  final Pivot pivot;

  ///
  final Dashboard dashboard;

  ///
  final void Function(BuildContext context, Pivot position)? onPivotPressed;

  ///
  final void Function(BuildContext context, Pivot position)?
      onPivotSecondaryPressed;

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

  void _update() {
    setState(() {});
  }
}

///
class Pivot extends ChangeNotifier {
  ///
  Pivot(Offset pivot) : _pivot = pivot;

  ///
  Pivot.fromMap(Map<String, dynamic> map)
      : _pivot = Offset(
          map['pivot.dx'] as double,
          map['pivot.dy'] as double,
        );
  Offset _pivot;

  ///
  Offset get pivot => _pivot;

  ///
  set pivot(Offset value) {
    _pivot = value;
    notifyListeners();
  }

  ///
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pivot.dx': _pivot.dx,
      'pivot.dy': _pivot.dy,
    };
  }

  ///
  void setScale(double scale, Offset focalPoint, double factor) {
    pivot = ((pivot - focalPoint) / scale) * factor + focalPoint;
  }

  @override
  bool operator ==(Object other) => other is Pivot && other._pivot == _pivot;

  @override
  int get hashCode => _pivot.hashCode;
}
