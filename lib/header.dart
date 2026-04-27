import 'package:flutter/material.dart';
import 'package:silent_guardian/responsive.dart';
import 'sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool enableSignInNavigation;

  const AppHeader({super.key, this.enableSignInNavigation = true});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final logoSize = (R.width * 0.1).clamp(32.0, 52.0);
    final iconSize = (R.width * 0.07).clamp(22.0, 32.0);
    final titleFontSize = (R.width * 0.042).clamp(14.0, 18.0);

    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/images/silent_guardian_logo.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
          ),

          SizedBox(width: R.spacingSmall),
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
                              Text(
                                'Hello',
                                style: TextStyle(fontSize: R.fontMedium),
                              ),
                              SizedBox(height: R.spacingSmall),
                              Text(
                                user.email ?? 'No email',
                                style: TextStyle(fontWeight: FontWeight.bold,
                                  fontSize: R.fontMedium),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Close',
                                style: TextStyle(fontSize: R.fontMedium),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();

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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
