import 'package:flutter/material.dart';
import 'package:silent_guardian/responsive.dart';
import 'header.dart';

class FakeCallTriggerScreen extends StatelessWidget {
  const FakeCallTriggerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const AppHeader(enableSignInNavigation: false),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(R.paddingHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Fake Call Trigger",
                style: TextStyle(
                  fontSize: R.fontTitle,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: R.spacingLarge),

              Text(
                "To trigger a fake call, press the following buttons in order:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: R.fontMedium),
              ),

              SizedBox(height: R.spacingLarge),

              Text(
                "1. Volume Down \n"
                    "2. Volume Up \n"
                    "3. Volume Down ",
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