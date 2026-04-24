import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silent_guardian/fake_call_trigger.dart';
import 'header.dart';
import 'emergency_contacts.dart';
import 'emergency_message.dart';
import 'silent_panic_trigger.dart';
import 'package:silent_guardian/volume_listener_service.dart';
import 'accessibility_helper.dart';
import 'panic_listener.dart';
import 'sms_service.dart';
import 'emergency_service.dart';
import 'email_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  final bool showLoginSuccess;

  const HomeScreen({super.key, this.showLoginSuccess = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

  final SmsService smsService = SmsService();
  final EmergencyService emergencyService = EmergencyService();
  bool _accessibilityEnabled = false;
  bool _accessibilityDialogShown = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissionsSequentially();
    VolumeListenerService();

    // Flutter-side panic listener (works when app is in foreground/background)
    PanicListener.startListening(() {
      debugPrint("PANIC RECEIVED IN FLUTTER");
      triggerEmergency();
    });

    if (widget.showLoginSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully Logged In'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAccessibility());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ─── LOCATION ────────────────────────────────────────────────────────────────

  /// Saves location to SharedPreferences under keys Kotlin can also read.
  /// Flutter's shared_preferences prefixes keys with "flutter." automatically,
  /// so Kotlin reads them as "flutter.last_lat" / "flutter.last_lng".
  Future<void> _cacheLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_lat', lat);
    await prefs.setDouble('last_lng', lng);
    debugPrint("Location cached: $lat, $lng");
  }

  Future<String?> _getCachedLocationString() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('last_lat');
    final lng = prefs.getDouble('last_lng');
    if (lat != null && lng != null) {
      return 'https://maps.google.com/?q=$lat,$lng';
    }
    return null;
  }

  /// 3-tier fallback — never shows any OS dialog, never blocks the user.
  Future<String?> _getBestLocationString() async {
    try {
      final permission = await Geolocator.checkPermission();
      final hasPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (hasPermission) {
        // 1. Live GPS (short timeout)
        try {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
          ).timeout(const Duration(seconds: 3));
          await _cacheLocation(pos.latitude, pos.longitude);
          return 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}';
        } catch (_) {
          debugPrint("Live GPS timed out, trying last known…");
        }

        // 2. OS last-known fix (instant)
        try {
          final last = await Geolocator.getLastKnownPosition();
          if (last != null) {
            await _cacheLocation(last.latitude, last.longitude);
            return 'https://maps.google.com/?q=${last.latitude},${last.longitude}';
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint("Location check failed: $e");
    }

    // 3. Whatever we cached last time the app had a fix
    return _getCachedLocationString();
  }

  // ─── PERMISSIONS ─────────────────────────────────────────────────────────────

  Future<void> _requestPermissionsSequentially() async {
    // Only ask if not already granted — never re-prompts on subsequent launches
    if (!await Permission.sms.isGranted) {
      await Permission.sms.request();
    }
    if (!await Permission.location.isGranted) {
      await Permission.location.request();
    }
    // Warm up the location cache right after permissions confirmed
    await _getBestLocationString();
  }

  // ─── EMERGENCY (Flutter-side, used when app is alive) ────────────────────────

  Future<void> triggerEmergency() async {
    if (_isSending) return;
    _isSending = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final phones = await emergencyService.getPhones();
      final message = await emergencyService.getMessage();
      final locationString = await _getBestLocationString();

      final String fullMessage = locationString != null
          ? '$message\n\nMy location: $locationString'
          : message;

      final email1 = prefs.getString('email1') ?? '';
      final email2 = prefs.getString('email2') ?? '';
      final emailService = EmailService();
      bool smsSent = false;
      bool emailSent = false;

      if (phones.isEmpty && email1.isEmpty && email2.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No emergency contact saved. Please add one in Emergency Contacts."),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      for (final phone in phones) {
        try {
          await smsService.sendSMS(phone, fullMessage);
          smsSent = true;
        } catch (e) {
          debugPrint("Failed to send SMS to $phone: $e");
        }
      }

      if (email1.isNotEmpty) {
        try {
          await emailService.sendEmail(email1, fullMessage);
          emailSent = true;
        } catch (e) {
          debugPrint("Failed to send email to $email1: $e");
        }
      }

      if (email2.isNotEmpty) {
        try {
          await emailService.sendEmail(email2, fullMessage);
          emailSent = true;
        } catch (e) {
          debugPrint("Failed to send email to $email2: $e");
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((emailSent || smsSent)
                ? "Emergency alert sent"
                : "Failed to send emergency alert"),
            backgroundColor: (emailSent || smsSent) ? Colors.red : Colors.grey,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      await Future.delayed(const Duration(seconds: 5));
      _isSending = false;
    }
  }

  // ─── ACCESSIBILITY ───────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAccessibility();
    }
  }

  Future<void> _checkAccessibility() async {
    final enabled = await AccessibilityHelper.isAccessibilityEnabled();

    if (enabled) {
      if (_accessibilityDialogShown && mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
        _accessibilityDialogShown = false;
      }
      setState(() => _accessibilityEnabled = true);
      return;
    }

    if (_accessibilityDialogShown || !mounted) return;
    _accessibilityDialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Enable Panic Trigger"),
        content: const Text(
          "Silent Guardian requires Accessibility permission to detect "
              "the volume-button panic trigger. Tap Enable, turn it on, "
              "then come back — you won't be asked again.",
        ),
        actions: [
          TextButton(
            onPressed: () => AccessibilityHelper.openAccessibilitySettings(),
            child: const Text("Enable"),
          ),
        ],
      ),
    ).then((_) => _accessibilityDialogShown = false);
  }

  // ─── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const AppHeader(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _HomeIcon(
                          icon: Icons.people,
                          label: 'Emergency\nContacts',
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const EmergencyContactsScreen())),
                        ),
                        _HomeIcon(
                          icon: Icons.message,
                          label: 'Emergency\nMessages',
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const EmergencyMessageScreen())),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _HomeIcon(
                          icon: Icons.notifications_off,
                          label: 'Silent\nPanic Trigger',
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const SilentPanicTriggerScreen())),
                        ),
                        _HomeIcon(
                          icon: Icons.phone,
                          label: 'Fake Call',
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const FakeCallTriggerScreen())),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeIcon({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.35;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: size,
            height: size * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Icon(icon, size: size * 0.35, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}