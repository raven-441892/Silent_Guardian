import 'package:flutter/material.dart';
import 'package:silent_guardian/responsive.dart';
import 'header.dart';

class SilentPanicTriggerScreen extends StatelessWidget {
  const SilentPanicTriggerScreen({super.key});

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
            children:[
              Text(
                "Silent Emergency Trigger",
                style: TextStyle(
                  fontSize: R.fontTitle,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: R.spacingLarge),

              Text(
                "To trigger a silent emergency, press the following buttons in order:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: R.fontMedium),
              ),

              SizedBox(height: R.spacingLarge),

              Text(
                    "1. Volume Up \n"
                    "2. Volume Down \n"
                    "3. Volume Up ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.fontLarge,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: R.spacingLarge),

          Container(
            padding: EdgeInsets.all(R.spacingSmall),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(R.radius),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 20),
                SizedBox(width: R.spacingSmall),
                Expanded(
                  child: Text(
                    "After triggering, a 3-second timer will appear before sending alerts.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: R.fontSmall,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}