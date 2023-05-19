import 'package:flutter/material.dart';
import 'package:todo/colors.dart';

ThemeData theme() {
  return ThemeData(
    fontFamily: 'dove',
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
        backgroundColor: blackColor,
        elevation: 0,
      ),
    ),
  );
}
