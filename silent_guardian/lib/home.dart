import 'package:flutter/material.dart';
import 'header.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: const AppHeader(),
      //BODY
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            // 🔲 ICON GRID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HomeIcon(
                  icon: Icons.people,
                  label: 'Emergency\nContacts',
                  onTap: () {},
                ),
                _HomeIcon(
                  icon: Icons.message,
                  label: 'Emergency\nMessages',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 40),

// 🔲 SECOND ROW (Panic + PIN same style)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HomeIcon(
                  icon: Icons.notifications_off,
                  label: 'Silent\nPanic Trigger',
                  onTap: () {
                    // Panic mode later
                  },
                ),
                _HomeIcon(
                  icon: Icons.lock,
                  label: 'App\nPIN Code',
                  onTap: () {
                    // PIN setup later
                  },
                ),
              ],
            ),

            const SizedBox(height : 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HomeIcon(
                    icon: Icons.phone,
                    label: 'Fake Call',
                    onTap: (){

                    },
                )
              ],
            )

          ],
        ),
      ),
    );
  }
}

class _HomeIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
