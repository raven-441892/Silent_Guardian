import 'package:flutter/material.dart';
import 'header.dart';

class FakeCallTriggerScreen extends StatelessWidget {
  const FakeCallTriggerScreen({super.key});

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
                "Fake Call Trigger",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 30),

              Text(
                "To trigger a fake call, press the following buttons in order:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 30),

              Text(
                "1. Volume Down \n"
                    "2. Volume Up \n"
                    "3. Volume Down ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}