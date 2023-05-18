import 'package:flutter/material.dart';
import 'package:todo/screen/home_screen.dart';
import 'package:todo/theme.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme(),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
