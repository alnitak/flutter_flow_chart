import 'dart:ui';
import 'dart:convert';
import 'package:flutter_flow_chart/src/ui/draw_arrow.dart';
import 'package:flutter_flow_chart/src/ui/segment_handler.dart';

class ConnectionParams {
  final String destElementId;
  final ArrowParams arrowParams;
  final List<Pivot> pivots;

  ConnectionParams({
    required this.destElementId,
    required this.arrowParams,
    List<Pivot>? pivots,
  }) : pivots = pivots ?? [];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'destElementId': destElementId,
      'arrowParams': arrowParams.toMap(),
      'pivots': pivots.map((pivots) => pivots.toMap()).toList(),
    };
  }

  factory ConnectionParams.fromMap(Map<String, dynamic> map) {
    return ConnectionParams(
      destElementId: map['destElementId'] as String,
      arrowParams:
          ArrowParams.fromMap(map['arrowParams'] as Map<String, dynamic>),
      pivots: (map['pivots'] as List?)
              ?.map<Pivot>((pivot) => Pivot.fromMap(pivot))
              .toList() ??
          [],
    );
  }

  /// Divide the connection into segments
  void dissect(Offset point) {
    pivots.add(Pivot(point));
  }

  String toJson() => json.encode(
        toMap(),
      );

  factory ConnectionParams.fromJson(String source) =>
      ConnectionParams.fromMap(json.decode(source) as Map<String, dynamic>);
}
