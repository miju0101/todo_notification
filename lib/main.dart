import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:todo/screen/home_screen.dart';
import 'package:todo/service/todo_service.dart';
import 'package:todo/theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TodoService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("ko"),
      ],
      theme: theme(),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
