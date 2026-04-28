import 'package:flutter/material.dart';
import 'package:silent_guardian/responsive.dart';
import 'header.dart';
import 'home.dart';
import 'sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Widget screen for log in
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Controllers for user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Focus control for password field
  final FocusNode _passwordFocusNode = FocusNode();

  // Validation and UI state flags
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _passwordVisible = false;
  bool _loading = false;

  // Email validation using regex
  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Password validation (min 8 chars, letters, number, special char)
  bool _validatePassword(String password) {
    return RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_]).{8,}$')
        .hasMatch(password);
  }

  // Handles Firebase login
  Future<void> _signIn() async {
    // Prevent login if inputs are invalid
    if (!_isEmailValid || !_isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Firebase authentication request
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      // Navigate to Home on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(showLoginSuccess: true),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      // Handle login errors
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found for this email.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = e.message ?? 'Login failed';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      // Stop loading indicator
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    // Clean up controllers and focus nodes
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const AppHeader(enableSignInNavigation: false),
      resizeToAvoidBottomInset: true,

      // Scrollable layout for smaller screens
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: R.paddingHorizontal,
            vertical: R.paddingVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // Title
              Text(
                'Log In to your account',
                style: TextStyle(
                    fontSize: R.fontTitle, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: R.spacingLarge),

              // Email input field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(R.radius),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  errorText: _emailController.text.isEmpty || _isEmailValid
                      ? null : 'Please enter a valid email',
                ),
                onChanged: (value) {
                  setState(() => _isEmailValid = _validateEmail(value));
                },
              ),
              SizedBox(height: R.spacingSmall),

              // Password input field
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                enabled: _isEmailValid,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(R.radius),
                  ),
                  filled: true,
                  fillColor: _isEmailValid ? Colors.white : Colors.grey
                      .shade200,
                  errorText: _passwordController.text.isEmpty ||
                      _isPasswordValid
                      ? null
                      : 'Min 8 chars with letters, numbers & special character',

                  // Toggle password visibility
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible
                        ? Icons.visibility
                        : Icons
                        .visibility_off),
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                  ),
                ),
                onChanged: (value) =>
                    setState(() => _isPasswordValid = _validatePassword(value)),
              ),

              SizedBox(height: R.spacingMedium),

              // Login button
              SizedBox(
                height: R.buttonHeight,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.radius),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(height: 22, width: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : Text('Log In',
                      style: TextStyle(
                        fontSize: R.fontMedium,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ),
              ),

              SizedBox(height: R.spacingSmall),

              // Navigate to Sign Up
              SizedBox(
                height: R.buttonHeight,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()));

                    if (result == true && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Account created successfully'),
                        backgroundColor: Colors.green,
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.radius),
                    ),
                  ),
                  child: Text('Create New Account',
                      style: TextStyle(
                        fontSize: R.fontMedium,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ),
              ),

              SizedBox(height: R.spacingSmall),

              // Guest login option
              SizedBox(
                height: R.buttonHeight,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.radius),
                    ),
                  ),
                  child: Text('Log in as guest',
                      style: TextStyle(
                        fontSize: R.fontMedium,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
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