import 'package:banking_app22/consts/themes/app_theme.dart';
import 'package:banking_app22/screens/home_screen.dart';
import 'package:banking_app22/screens/main_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainScreen(),
    );
  }
}
