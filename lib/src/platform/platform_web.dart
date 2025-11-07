/// Returns true if the current platform is a mobile platform (Android or iOS).
bool isMobile() {
  return false;
}

/// Saves dashboard data.
void saveDashboardData(String filePath, String data) {
  throw UnsupportedError('Saving dasboard data is not supported on web.');
}

/// Load dashboard data.
String? readDashboardData(String filePath) {
  throw UnsupportedError('Loading dasboard data is not supported on web.');
}
