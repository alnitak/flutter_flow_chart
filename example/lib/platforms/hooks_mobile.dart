import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:path_provider/path_provider.dart' as path;

/// Save dashboard to file
Future<void> saveDashboard(Dashboard dashboard) async {
  final appDocDir = await path.getApplicationDocumentsDirectory();
  dashboard.saveDashboard('${appDocDir.path}/FLOWCHART.json');
}

/// Load dashboard from file
Future<void> loadDashboard(Dashboard dashboard) async {
  final appDocDir = await path.getApplicationDocumentsDirectory();
  dashboard.loadDashboard('${appDocDir.path}/FLOWCHART.json');
}
