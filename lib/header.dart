import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool enableSignInNavigation;

  const AppHeader({super.key, this.enableSignInNavigation = true});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 0.1;

    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/images/silent_guardian_logo.png',
            width: logoSize.clamp(32.0, 52.0),
            height: logoSize.clamp(32.0, 52.0),
            fit: BoxFit.contain,
          ),

          const SizedBox(width: 8),
          const Flexible(
            child: Text(
              'Silent Guardian',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
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
                          title: const Text('Account'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hello',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user.email ?? 'No email',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
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
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
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
