import 'package:flutter/material.dart';

const Color _customColor = Color.fromARGB(255, 202, 18, 18);

const List<Color> _colorThemes = [
  _customColor,
  Colors.blue,
  Color.fromARGB(255, 103, 155, 44),
  Colors.green,
  Color.fromARGB(255, 255, 230, 3),
  Colors.orange,
  Colors.pink,
];

class AppTheme {
  final int selectedColor;

  AppTheme({this.selectedColor = 0})
      : assert(selectedColor >= 0 && selectedColor <= _colorThemes.length - 1,
            'Colors must be between 0 and ${_colorThemes.length}');

  ThemeData theme() {
    return ThemeData(
        useMaterial3: true, 
        colorSchemeSeed: _colorThemes[selectedColor],
        // brightness: Brightness.dark
      );
  }
}