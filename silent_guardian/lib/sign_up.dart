import 'package:flutter/material.dart';
import 'header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isEmailValid = false;
  bool _isUsernameValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _loading = false;

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  bool _validateEmail(String email) {
    return RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);
  }

  bool _validateUsername(String username) {
    return username.length >= 3;
  }

  // Password validation: at least 8 chars, letters, numbers, special char
  bool _validatePassword(String password) {
    return RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_]).{8,}$'
    ).hasMatch(password);
  }

  // Confirm password validation
  bool _validateConfirmPassword(String confirmPassword) {
    return confirmPassword == _passwordController.text;
  }

  // --- Generate OTP ---
  String _generateOtp() {
    return (Random().nextInt(900000) + 100000).toString(); // 6-digit
  }

  void _signUp() async {
    if (!_isEmailValid || !_isUsernameValid || !_isPasswordValid || !_isConfirmPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Create user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await userCredential.user?.sendEmailVerification();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Please verify your email before login.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Signup failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // HEADER: same as SignInScreen / HomeScreen
      appBar: const AppHeader(enableSignInNavigation: false),

      // BODY: placeholder for sign-up form
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),

              const Text(
                'Create your new account',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  errorText: _emailController.text.isEmpty || _isEmailValid
                      ? null
                      : 'Please enter a valid email',
                ),
                onChanged: (value) {
                  setState(() {
                    _isEmailValid = _validateEmail(value);
                  });
                },
              ),
              const SizedBox(height: 20),

              // USERNAME
              TextField(
                controller: _usernameController,
                focusNode: _usernameFocusNode,
                enabled: _isEmailValid,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: _isEmailValid
                      ? Colors.white
                      : Colors.grey.shade200,
                  errorText: _usernameController.text.isEmpty ||
                      _isUsernameValid
                      ? null
                      : 'Username must be at least 3 characters',
                ),
                onChanged: (value) {
                  setState(() {
                    _isUsernameValid = _validateUsername(value);
                  });
                },
                onSubmitted: (_) {
                  if (_isUsernameValid) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  }
                },
              ),

              const SizedBox(height: 20),

              // Password Field
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                enabled: _isEmailValid,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: ' Create Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor:
                  _isEmailValid ? Colors.white : Colors.grey.shade200,
                  errorText: _passwordController.text.isEmpty ||
                      _isPasswordValid
                      ? null
                  //allows special characters like ! @ # $ % ^ & * ( ) , . ? " : { } | < > _)
                      : 'Password must be at least 8 characters long with \nalphabets, numbers'
                      ' & special character',

                  // Show/hide button
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _isPasswordValid = _validatePassword(value);
                  });
                },
              ),

              const SizedBox(height: 20),

              // Confirm Password Field
              TextField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                enabled: _isPasswordValid,
                obscureText: !_confirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: _isPasswordValid ? Colors.white : Colors.grey.shade200,
                  errorText: _confirmPasswordController.text.isEmpty || _isConfirmPasswordValid
                      ? null
                      : 'Passwords do not match',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _isConfirmPasswordValid = _validateConfirmPassword(value);
                  });
                },
              ),
              const SizedBox(height:20),

              // Sign Up Button
              _loading
                  ? const CircularProgressIndicator()
                  :SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create New Account',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
