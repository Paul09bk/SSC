import 'package:flutter/material.dart';
import 'package:flutter_ssc/screens/user/tamagotchi_screen.dart';
import 'package:flutter_ssc/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sunday Sport Club',
      theme: AppTheme.darkTheme,
      home: const TamagotchiScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}