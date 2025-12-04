// Helper to update the browser's theme-color meta tag for Flutter Web PWA.
// This syncs the browser bar color with the app's dark/light theme dynamically.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show document, MetaElement;
import 'package:spotify/core/configs/theme/app_colors.dart';

/// Updates the theme-color meta tag in index.html to match the current theme.
/// Call this whenever the app theme changes to prevent flicker or mismatched colors.
///
/// [isDarkMode] - true for dark theme (AppColors.darkBackground), false for light theme (AppColors.lightBackground).
void updateThemeColor(bool isDarkMode) {
  try {
    final meta =
        html.document.getElementById('theme-color-meta') as html.MetaElement?;
    if (meta != null) {
      final color = isDarkMode
          ? AppColors.darkBackground
          : AppColors.lightBackground;
      meta.content =
          '#${color.value.toRadixString(16).substring(2).padLeft(6, '0')}';
    }
  } catch (e) {
    // Ignore errors on non-web platforms (dart:html only available on web)
  }
}
