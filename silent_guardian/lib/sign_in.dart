import 'package:flutter/material.dart';
import 'header.dart';
import 'sign_up.dart';

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

  bool _validateEmail(String email) {
    return RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);
  }

  // Password validation: at least 8 chars, letters, numbers, special char
  bool _validatePassword(String password) {
    return RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_]).{8,}$'
    ).hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // HEADER: same as HomeScreen
      appBar: const AppHeader(enableSignInNavigation: false,),
      // BODY: Login form
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),

              const Text(
                'Log In to your account',
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

                  if (_isEmailValid) {
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
                  labelText: 'Password',
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
                      :'Password must be at least 8 characters long with \nalphabets, numbers'
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

              const SizedBox(height: 10),
              // Forgot password (left aligned)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    // Add forgot password logic
                  },
                  child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                      ),
                  ),
                ),
              ),

              const SizedBox(height: 5),
              // Log In Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Add sign-in logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder:(context)=> const SignUpScreen()),
                    );
                  },
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
