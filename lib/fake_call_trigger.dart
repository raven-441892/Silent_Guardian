import 'package:flutter/material.dart';
import 'package:silent_guardian/responsive.dart';
import 'header.dart';

// Screen showing fake call trigger instructions
class FakeCallTriggerScreen extends StatelessWidget {
  const FakeCallTriggerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);    // Initialize responsive sizing
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const AppHeader(enableSignInNavigation: false),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(R.paddingHorizontal),   // Responsive padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                "Fake Call Trigger",
                style: TextStyle(
                  fontSize: R.fontTitle,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: R.spacingLarge),

              // Instruction text
              Text(
                "To trigger a fake call, press the following buttons in order:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: R.fontMedium),
              ),

              SizedBox(height: R.spacingLarge),

              // Button sequence steps
              Text(
                "1. Power Button \n"
                    "2. Volume Down \n"
                    "3. Volume Up \n"
                    "4. Volume Down ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.fontLarge,
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