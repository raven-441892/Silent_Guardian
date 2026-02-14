import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'dart:math';

class OtpScreen extends StatefulWidget {
  final String email;
  final String username;
  final String generatedOtp;

  const OtpScreen({super.key, required this.email, required this.username, required this.generatedOtp});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  bool _loading = false;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() {
    String enteredOtp = _controllers.map((c) => c.text).join();
    if (enteredOtp == widget.generatedOtp) {
      // OTP correct → go to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect OTP, try again'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resendOtp() {
    setState(() {
      // regenerate OTP
      String newOtp = (100000 + (Random().nextInt(900000))).toString();
      debugPrint("New OTP: $newOtp");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent! Check console for now.')),
      );
    });
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text(
          "OTP Verification",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            const Icon(Icons.lock_outline, size: 80, color: Colors.blue),

            const SizedBox(height: 20),

            const Text(
              "Enter the 6-digit OTP sent to your email",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _otpBox(index)),
            ),

            const SizedBox(height: 40),

            _loading
              ?const CircularProgressIndicator()
              : SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Verify OTP",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            TextButton(onPressed: _resendOtp, child: const Text("Resend OTP")),
          ],
        ),
      ),
    );
  }
}
