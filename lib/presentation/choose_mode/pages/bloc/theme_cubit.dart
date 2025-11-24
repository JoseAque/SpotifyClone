import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void updateTheme(ThemeMode themeMode) => emit(themeMode);

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    final themeMode = json['themeMode'] as String?;
    if (themeMode == null) return null;
    return ThemeMode.values.firstWhere(
      (mode) => mode.toString() == 'ThemeMode.$themeMode',
      orElse: () => ThemeMode.system,
    );
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    return {'themeMode': state.toString().split('.').last};
  }
}
