import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:silent_guardian/responsive.dart';
import 'otp_email_service.dart';

// OTP verification screen
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
  // Controllers for 6 OTP boxes
  final List<TextEditingController> _controllers =
    List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // Store OTP in a local variable that survives brief backgrounding
  late String _currentOtp;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.generatedOtp;    // Store initial OTP
  }

  @override
  void dispose() {
    // Clean up controllers & focus nodes
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  // Verify entered OTP
  Future<void> _verifyOtp() async {
    final entered = _controllers.map((c) => c.text).join();

    // Check if full OTP entered
    if (entered.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter the full 6-digit code'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Check if OTP matches
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

  // Resend new OTP
  Future<void> _resendOtp() async {
    final newOtp = (100000 + Random().nextInt(900000)).toString();
    setState(() => _currentOtp = newOtp);

    // Clear input fields
    for (final c in _controllers) c.clear();
    _focusNodes.first.requestFocus();

    // Send OTP via email
    final sent = await OtpEmailService.sendOtp(widget.email, newOtp);
    if (!mounted) return;

    // Show result
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(sent ? 'OTP resent to ${widget.email}' : 'Failed to resend OTP'),
      backgroundColor: sent ? Colors.green : Colors.red,
    ));
  }

  // Single OTP input box
  Widget _otpBox(int index) {
    final boxSize = (R.width - R.paddingHorizontal * 2) / 8;

    return SizedBox(
      width: boxSize.clamp(36.0, 52.0),

      child: KeyboardListener(
        focusNode: FocusNode(),

        // Handle backspace navigation
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

          style: TextStyle(fontSize: R.fontLarge, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.radius)),
          ),

          // Handle typing navigation
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
    R.init(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,

        // Screen title
        title: Text('OTP Verification',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: R.fontLarge)),

        centerTitle: true,
        automaticallyImplyLeading: !_loading,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: R.paddingHorizontal,
            vertical: R.paddingVertical,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: R.spacingLarge),

              // Lock icon
              Icon(
                Icons.lock_outline,
                size: (R.width * 0.18).clamp(56.0, 80.0),
                color: Colors.blue,
              ),

              SizedBox(height: R.spacingMedium),

              // Instruction text
              Text(
                'Enter the 6-digit OTP sent to\n${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: R.fontMedium),
              ),

              SizedBox(height: R.spacingSmall),

              // Hint text
              Text(
                'Check your spam folder if not received.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.fontSmall,
                  color: Colors.grey,
                ),
              ),

              SizedBox(height: R.spacingLarge),

              // OTP input row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, _otpBox),
              ),

              SizedBox(height: R.spacingLarge),

              // Verify button / loading
              _loading
                  ? Column(children: [
                const CircularProgressIndicator(),
                SizedBox(height: R.spacingSmall),
                Text(
                  'Verifying OTP...',
                  style: TextStyle(fontSize: R.fontMedium),
                ),
              ])
                  : SizedBox(
                width: double.infinity,
                height: R.buttonHeight,

                child: ElevatedButton(
                  onPressed: _verifyOtp,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.radius),
                    ),
                  ),

                  child: Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: R.fontMedium,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: R.spacingSmall),

              // Resend OTP button
              TextButton(
                onPressed: _loading ? null : _resendOtp,
                child: Text(
                  'Resend OTP',
                  style: TextStyle(fontSize: R.fontMedium),
                ),
              ),

              SizedBox(height: R.spacingMedium),
            ],
          ),
        ),
      ),
    );
  }
}