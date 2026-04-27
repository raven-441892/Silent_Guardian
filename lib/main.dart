import 'package:flutter/material.dart';
import 'package:silent_guardian/sms_service.dart';
import 'home.dart';
import 'sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIXED: Always pass options to avoid initialization failures
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SilentGuardianApp());
}

class SilentGuardianApp extends StatelessWidget {
  const SilentGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Silent Guardian',
      // Check if user is already signed in on app launch
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Auto-login: if already signed in go straight to HomeScreen
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }
          return const SignInScreen();
        },
      ),
    );
  }
}