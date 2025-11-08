import 'dart:io';

/// Returns true if the current platform is a mobile platform (Android or iOS).
bool isMobile() {
  return Platform.isAndroid || Platform.isIOS;
}

/// Saves dashboard data.
void saveDashboardData(String filePath, String data) {
  File(filePath).writeAsStringSync(data, flush: true);
}

/// Load dashboard data.
String? readDashboardData(String filePath) {
  final f = File(filePath);
  return f.readAsStringSync();
}
