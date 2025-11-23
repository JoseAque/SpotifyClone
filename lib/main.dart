import 'package:flutter/material.dart';
import 'package:spotify/core/configs/theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  // Este es un StatelessWidget porque este widget no necesita guardar ni actualizar estado interno. Su apariencia depende únicamente de los parámetros de entrada.

  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: AppTheme.lightTheme, home: Container());
  }
}
