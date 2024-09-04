import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:web/web.dart' as web;

/// Save dashboard to file
Future<void> saveDashboard(Dashboard dashboard) async {
  final bytes = utf8.encode(dashboard.prettyJson());
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = 'data:application/octet-stream;base64,${base64Encode(bytes)}'
    ..style.display = 'none'
    ..download = 'FLOWCHART.json';
  web.document.body!.appendChild(anchor);
  anchor.click();
  web.document.body!.removeChild(anchor);
}

/// Load dashboard from file
Future<void> loadDashboard(Dashboard dashboard) async {
  final result = await FilePicker.platform.pickFiles();
  if (result == null) return;
  dashboard.loadDashboardData(
    jsonDecode(String.fromCharCodes(result.files.first.bytes!))
        as Map<String, dynamic>,
  );
}
