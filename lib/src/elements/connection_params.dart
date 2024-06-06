import 'dart:convert';
import 'dart:ui';

import 'package:flutter_flow_chart/src/ui/draw_arrow.dart';
import 'package:flutter_flow_chart/src/ui/segment_handler.dart';

/// Connection parameters.
class ConnectionParams {
  ///
  ConnectionParams({
    required this.destElementId,
    required this.arrowParams,
    List<Pivot>? pivots,
  }) : pivots = pivots ?? [];

  ///
  factory ConnectionParams.fromMap(Map<String, dynamic> map) {
    return ConnectionParams(
      destElementId: map['destElementId'] as String,
      arrowParams:
          ArrowParams.fromMap(map['arrowParams'] as Map<String, dynamic>),
      pivots: (map['pivots'] as List?)
              ?.map<Pivot>(
                (pivot) => Pivot.fromMap(pivot as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  ///
  factory ConnectionParams.fromJson(String source) =>
      ConnectionParams.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Unique element ID where this connection points.
  final String destElementId;

  /// Arrow parameters.
  final ArrowParams arrowParams;

  /// List of pivot points for the segmented arrow style.
  final List<Pivot> pivots;

  ///
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'destElementId': destElementId,
      'arrowParams': arrowParams.toMap(),
      'pivots': pivots.map((pivots) => pivots.toMap()).toList(),
    };
  }

  /// Divide the connection into segments
  void dissect(Offset point) {
    pivots.add(Pivot(point));
  }

  ///
  String toJson() => json.encode(toMap());
}
