import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'otp_email_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String generatedOtp;

  /// Called after the user enters the correct OTP.
  /// Should return true if account creation succeeded, false otherwise.
  final Future<void> Function() onVerified;

  const OtpScreen({
    super.key,
    required this.email,
    required this.generatedOtp,
    required this.onVerified,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // Store OTP in a local variable that survives brief backgrounding
  late String _currentOtp;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.generatedOtp;
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final entered = _controllers.map((c) => c.text).join();

    if (entered.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter the full 6-digit code'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (entered != _currentOtp) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Incorrect OTP, try again'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (!mounted) return;

    //Pop OTP to SignUp
    Navigator.pop(context);

    //Pop SignUp to SignIn and send result
    Navigator.pop(context, true);

    // Create account in the background (after popping)
    widget.onVerified();
  }

  Future<void> _resendOtp() async {
    final newOtp = (100000 + Random().nextInt(900000)).toString();
    setState(() => _currentOtp = newOtp);

    for (final c in _controllers) c.clear();
    _focusNodes.first.requestFocus();

    final sent = await OtpEmailService.sendOtp(widget.email, newOtp);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(sent ? 'OTP resent to ${widget.email}' : 'Failed to resend OTP'),
      backgroundColor: sent ? Colors.green : Colors.red,
    ));
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 44,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          // Handle physical backspace key
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            if (_controllers[index].text.isEmpty && index > 0) {
              _controllers[index - 1].clear();
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          maxLength: 1,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              // Move forward
              if (index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else {
                // Last box — dismiss keyboard
                _focusNodes[index].unfocus();
              }
            } else {
              // Deleted — move back
              if (index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text('OTP Verification',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: !_loading,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Icon(Icons.lock_outline, size: 72, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                'Enter the 6-digit OTP sent to\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Check your spam folder if not received.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, _otpBox),
              ),
              const SizedBox(height: 32),
              _loading
                  ? const Column(children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Verifying OTP...'),
              ])
                  : SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Verify OTP',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loading ? null : _resendOtp,
                child: const Text('Resend OTP'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
