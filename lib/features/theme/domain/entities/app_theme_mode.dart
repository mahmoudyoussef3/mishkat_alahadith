enum AppThemeMode {
  light,
  dark;

  bool get isDark => this == AppThemeMode.dark;

  AppThemeMode get toggled => isDark ? AppThemeMode.light : AppThemeMode.dark;
}
