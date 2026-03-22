import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const LearnvisApp());
}

class LearnvisApp extends StatelessWidget {
  const LearnvisApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learnvis - Interactive Physics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
