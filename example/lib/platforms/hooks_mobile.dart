import 'dart:io';
import 'dart:typed_data';

import 'package:example/example_data_serializer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:path_provider/path_provider.dart' as path;

/// Save dashboard to file
Future<void> saveDashboard(Dashboard<ExampleData> dashboard) async {
  final appDocDir = await path.getApplicationDocumentsDirectory();
  dashboard.saveDashboard('${appDocDir.path}/FLOWCHART.json');
}

/// Load dashboard from file
Future<void> loadDashboard(Dashboard<ExampleData> dashboard) async {
  final appDocDir = await path.getApplicationDocumentsDirectory();
  dashboard.loadDashboard('${appDocDir.path}/FLOWCHART.json');
}

/// Pick image
Future<Uint8List?> pickImageBytes() async {
  final pickResult = await FilePicker.platform.pickFiles(
    type: FileType.image,
  );
  if (pickResult == null) return null;
  return File(pickResult.files.single.path!).readAsBytesSync();
}
