import 'package:flutter/material.dart';
import 'header.dart';

class SilentPanicTriggerScreen extends StatelessWidget {
  const SilentPanicTriggerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const AppHeader(enableSignInNavigation: false),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [

              Text(
                "Silent Emergency Trigger",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 30),

              Text(
                "To trigger a silent emergency, press the following buttons in order:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 30),

              Text(
                    "1. Volume Up (🔊)\n"
                    "2. Volume Down (🔉)\n"
                    "3. Volume Up (🔊)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 40),

              Text(
                "⚠ After triggering, a 3-second timer will appear before sending alerts.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}