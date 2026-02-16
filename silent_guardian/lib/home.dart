import 'package:flutter/material.dart';
import 'header.dart';
import 'emergency_contacts.dart';
import 'emergency_message.dart';
import 'silent_panic_trigger.dart';
import 'package:silent_guardian/volume_listener_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final VolumeListenerService _volumeService = VolumeListenerService();

  @override
  void initState() {
    super.initState();

    // Start listening after build
    Future.microtask(() {
      _volumeService.startListening(context);
    });
  }

  @override
  void dispose() {
    _volumeService.dispose(); // if you added dispose()
    super.dispose();
  }

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

            // ICON GRID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HomeIcon(
                  icon: Icons.people,
                  label: 'Emergency\nContacts',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmergencyContactsScreen(),
                      ),
                    );
                  },
                ),
                _HomeIcon(
                  icon: Icons.message,
                  label: 'Emergency\nMessages',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmergencyMessageScreen(),
                      ),
                    );
                  },
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SilentPanicTriggerScreen(),
                      ),
                    );
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
