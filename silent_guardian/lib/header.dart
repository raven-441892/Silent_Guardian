import 'package:flutter/material.dart';
import 'sign_in.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool enableSignInNavigation;

  const AppHeader({super.key, this.enableSignInNavigation = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/images/silent_guardian_logo.png',
            width: 60,
          ),

          const SizedBox(width: 8),
          const Text(
            'Silent Guardian',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Builder(
            builder: (context) {
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: enableSignInNavigation
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignInScreen(),
                    ),
                  );
                }
                    : null,
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
