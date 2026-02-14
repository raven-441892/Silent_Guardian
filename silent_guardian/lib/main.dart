import 'package:flutter/material.dart';
import 'home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (Firebase.apps.isEmpty) {
      // options: DefaultFirebaseOptions.currentPlatform,
  await Firebase.initializeApp();
  //}
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
