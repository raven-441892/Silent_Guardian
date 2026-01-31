import 'package:flutter/material.dart';
import 'home.dart';
void main() {
  runApp(const SilentGuardianApp());
}

class SilentGuardianApp extends StatelessWidget {
  const SilentGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Silent Guardian',
      home: const HomeScreen(),
    );
  }
}
