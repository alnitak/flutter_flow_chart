import 'package:flutter_flow_chart/flutter_flow_chart.dart';

///
class ExampleDataSerializer
    with DataSerializer<ExampleData, Map<String, dynamic>> {
  @override
  ExampleData? fromJson(Map<String, dynamic>? source) {
    if (source == null) return null;

    return ExampleData(
      name: source['name'] as String,
      value: source['value'] as int,
    );
  }

  @override
  Map<String, dynamic>? toJson(ExampleData? data) {
    if (data == null) return null;

    return <String, dynamic>{
      'name': data.name,
      'value': data.value,
    };
  }
}

///
class ExampleData {
  ///
  ExampleData({
    required this.name,
    required this.value,
  });

  ///
  final String name;

  ///
  final int value;
}
