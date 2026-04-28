import 'package:flutter/material.dart';
import 'package:silent_guardian/responsive.dart';
import 'sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Custom reusable app header
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool enableSignInNavigation;    // Toggle sign-in navigation

  const AppHeader({super.key, this.enableSignInNavigation = true});

  @override
  Widget build(BuildContext context) {
    R.init(context);    // Initialize responsive values

    // Responsive sizes
    final logoSize = (R.width * 0.1).clamp(32.0, 52.0);
    final iconSize = (R.width * 0.07).clamp(22.0, 32.0);
    final titleFontSize = (R.width * 0.042).clamp(14.0, 18.0);

    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      title: Row(
        children: [
          // App logo
          Image.asset(
            'assets/images/silent_guardian_logo.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
          ),

          SizedBox(width: R.spacingSmall),

          // App title
          Flexible(
            child: Text(
              'Silent Guardian',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: titleFontSize,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),

          // Profile icon with tap action
          Builder(
            builder: (context) {
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    final user = FirebaseAuth.instance.currentUser;

                    if (user == null) {
                      //Not logged in then go to SignIn
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignInScreen(),
                        ),
                      );
                    } else {
                      //Logged in then show user popup
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(
                              'Account',
                              style: TextStyle(fontSize: R.fontLarge),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              //Greeting text
                              Text(
                                'Hello',
                                style: TextStyle(fontSize: R.fontMedium),
                              ),
                              SizedBox(height: R.spacingSmall),

                              // Show user email
                              Text(
                                user.email ?? 'No email',
                                style: TextStyle(fontWeight: FontWeight.bold,
                                  fontSize: R.fontMedium),
                              ),
                            ],
                          ),
                          actions: [
                            // Close dialog
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Close',
                                style: TextStyle(fontSize: R.fontMedium),
                              ),
                            ),

                            // Logout button
                            TextButton(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();

                                // Navigate to sign-in after logout
                                if (context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignInScreen(),
                                    ),
                                        (route) => false,
                                  );
                                }
                              },
                              child:Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: R.fontMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },

                // Profile icon UI
                child: Container(
                  padding: EdgeInsets.all(R.spacingSmall * 0.6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // AppBar height
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
