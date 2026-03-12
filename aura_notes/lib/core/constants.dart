/// App-wide constants for AuraNotes.
class AppConstants {
  AppConstants._();

  static const String appName = 'AuraNotes';
  static const String dbName = 'aura_notes.db';
  static const int dbVersion = 1;

  // Sidebar
  static const double sidebarWidth = 280.0;
  static const double sidebarCollapsedWidth = 0.0;

  // Editor
  static const int autoSaveDelayMs = 500;

  // Animation durations (ms)
  static const int sidebarAnimationMs = 250;
  static const int fadeAnimationMs = 200;
  static const int slideAnimationMs = 300;
}
