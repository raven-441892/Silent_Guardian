import 'dart:math';
import 'package:flutter/material.dart';
import 'package:silent_guardian/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'header.dart';
import 'otp_screen.dart';
import 'otp_email_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Input controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Focus control for form navigation
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  // Validation & UI state
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _loading = false;

  // Password visibility toggles
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  // Email validation (regex)
  bool _validateEmail(String v) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v);

  // Password validation (min 8 chars, letters, number, special char)
  bool _validatePassword(String v) =>
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_]).{8,}$')
          .hasMatch(v);

  // Confirm password match check
  bool _validateConfirmPassword(String v) => v == _passwordController.text;

  // Generate 6-digit OTP
  String _generateOtp() => (Random().nextInt(900000) + 100000).toString();

  // Sends OTP after validation and email uniqueness check
  Future<void> _sendOtpAndNavigate() async {
    if (!_isEmailValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a valid email'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final email = _emailController.text.trim();

    setState(() => _loading = true);

    try {
      //Check if email already exists in Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This email is already registered. Please go to Sign In.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Email is available then proceed with password validation
      if (!_isPasswordValid || !_isConfirmPasswordValid) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill password fields correctly'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      // Generate and send OTP via email service
      final otp = _generateOtp();
      final sent = await OtpEmailService.sendOtp(email, otp);

      if (!sent) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not send OTP. Check your internet.'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      if (!mounted) return;

      // Navigate to OTP verification screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            email: email,
            generatedOtp: otp,
            onVerified: () => _createAccount(email),
          ),
        ),
      );

      // Return success to previous screen if verified
      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Handle unexpected errors
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Creates Firebase user + Firestore record
  Future<void> _createAccount(String email) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      // Store user data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } on FirebaseAuthException catch (e) {

      // Handle Firebase auth errors
      String message = 'Account creation failed';

      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered. Please sign in.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      } else {
        message = e.message ?? message;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      // Generic fallback error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unexpected error. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Clean up controllers & focus nodes
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const AppHeader(enableSignInNavigation: false),

      // Scrollable form layout
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: R.paddingHorizontal,
            vertical: R.paddingVertical,
          ),
          child: Column(
            children: [
              SizedBox(height: R.spacingLarge),

              // Screen title
              Text(
                'Create your new account',
                style: TextStyle(fontSize: R.fontTitle, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: R.spacingLarge),

              // Email input
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(R.radius)),
                  filled: true,
                  fillColor: Colors.white,
                  errorText: _emailController.text.isEmpty || _isEmailValid
                      ? null
                      : 'Please enter a valid email',
                ),
                onChanged: (v) =>
                    setState(() => _isEmailValid = _validateEmail(v)),
              ),

              SizedBox(height: R.spacingMedium),

              // Password input
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                enabled: _isEmailValid,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Create Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(R.radius)),
                  filled: true,
                  fillColor:
                  _isEmailValid ? Colors.white : Colors.grey.shade200,
                  errorText: _passwordController.text.isEmpty || _isPasswordValid
                      ? null
                      : 'Min 8 chars with letters, numbers & special char',

                  // Toggle visibility
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                  ),
                ),
                onChanged: (v) =>
                    setState(() => _isPasswordValid = _validatePassword(v)),
              ),
              SizedBox(height: R.spacingMedium),

              // Confirm Password input
              TextField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                enabled: _isPasswordValid,
                obscureText: !_confirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(R.radius)),
                  filled: true,
                  fillColor: _isPasswordValid
                      ? Colors.white
                      : Colors.grey.shade200,
                  errorText: _confirmPasswordController.text.isEmpty ||
                      _isConfirmPasswordValid
                      ? null
                      : 'Passwords do not match',

                  // Toggle confirm visibility
                  suffixIcon: IconButton(
                    icon: Icon(_confirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(() =>
                    _confirmPasswordVisible = !_confirmPasswordVisible),
                  ),
                ),
                onChanged: (v) => setState(
                        () => _isConfirmPasswordValid =
                        _validateConfirmPassword(v)),
              ),

              SizedBox(height: R.spacingMedium),

              // Submit button / loading state
              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                height: R.buttonHeight,
                child: ElevatedButton(
                  onPressed: _sendOtpAndNavigate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.radius)),
                  ),
                  child: Text(
                    'Create New Account',
                    style: TextStyle(
                        fontSize: R.fontMedium,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: R.spacingLarge),
            ],
          ),
        ),
      ),
    );
  }
}