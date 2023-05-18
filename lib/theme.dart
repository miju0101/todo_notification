import 'package:flutter/material.dart';
import 'package:todo/colors.dart';

ThemeData theme() {
  return ThemeData(
    backgroundColor: Colors.white,
    fontFamily: 'omu',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: secondColor,
        elevation: 0,
      ),
    ),
  );
}
