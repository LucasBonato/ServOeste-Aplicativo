import 'dart:ui';

abstract class AppThemes {
  const AppThemes();

  static final Map<String, Brightness> _themeBrightness = {
    "default": Brightness.light
  };
}