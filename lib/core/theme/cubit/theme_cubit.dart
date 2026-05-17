import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState());

  void setTheme(String themeMode) {
    final mode = _parseThemeMode(themeMode);
    emit(ThemeState(themeMode: mode));
  }

  void setThemeMode(ThemeMode mode) {
    emit(ThemeState(themeMode: mode));
  }

  ThemeMode _parseThemeMode(String themeMode) {
    switch (themeMode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
