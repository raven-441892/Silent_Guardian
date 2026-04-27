import 'package:flutter/material.dart';
import 'package:silent_guardian/responsive.dart';
import 'header.dart';
import 'home.dart';
import 'sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();

  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _passwordVisible = false;
  bool _loading = false;

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _validatePassword(String password) {
    return RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_]).{8,}$')
        .hasMatch(password);
  }

  Future<void> _signIn() async {
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      // FIXED: Removed emailVerified check — OTP already verified the user's email.
      // Forcing emailVerified would lock out all users since we don't send
      // Firebase's own verification email anymore.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(showLoginSuccess: true),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
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
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: R.paddingHorizontal,
            vertical: R.paddingVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Log In to your account',
                style: TextStyle(
                    fontSize: R.fontTitle, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: R.spacingLarge),

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
                  if (_isEmailValid) FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
              ),
              SizedBox(height: R.spacingSmall),

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
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible ? Icons.visibility : Icons
                        .visibility_off),
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                  ),
                ),
                onChanged: (value) =>
                    setState(() => _isPasswordValid = _validatePassword(value)),
              ),
              SizedBox(height: R.spacingMedium),

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