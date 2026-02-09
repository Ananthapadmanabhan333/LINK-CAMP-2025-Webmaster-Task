import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'features/landing/landing_screen.dart';

void main() {
  runApp(const HybridAthleteApp());
}

class HybridAthleteApp extends StatelessWidget {
  const HybridAthleteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hybrid Athlete AI',
      theme: AppTheme.darkTheme,
      home: const LandingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
