import 'package:flutter/material.dart';
import 'header.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends State<EmergencyContactsScreen> {

  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _phone2Controller = TextEditingController();
  final TextEditingController _email1Controller = TextEditingController();
  final TextEditingController _email2Controller = TextEditingController();

  bool _isPhone1Valid = false;
  bool _isPhone2Valid = true; // optional
  bool _isEmail1Valid = false;
  bool _isEmail2Valid = true; // optional

  bool _validatePhone(String value) {
    return RegExp(r'^[0-9]{7,15}$').hasMatch(value);
  }

  bool _validateEmail(String value) {
    return RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(value);
  }

  void _saveContacts() {
    if (_isPhone1Valid && _isEmail1Valid && _isPhone2Valid && _isEmail2Valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Emergency contacts saved"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fix the errors before saving"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _email1Controller.dispose();
    _email2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const AppHeader(enableSignInNavigation: false),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            const Text(
              "Emergency Contacts",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            // PRIMARY PHONE (Required)
            TextField(
              controller: _phone1Controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Primary Phone Number *",
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                errorText: _phone1Controller.text.isEmpty || _isPhone1Valid
                    ? null
                    : "Enter valid phone number (7-15 digits)",
              ),
              onChanged: (value) {
                setState(() {
                  _isPhone1Valid = _validatePhone(value);
                });
              },
            ),

            const SizedBox(height: 20),

            // SECONDARY PHONE (Optional)
            TextField(
              controller: _phone2Controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Secondary Phone (Optional)",
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                errorText: _phone2Controller.text.isEmpty || _isPhone2Valid
                    ? null
                    : "Enter valid phone number",
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _isPhone2Valid = true;
                  } else {
                    _isPhone2Valid = _validatePhone(value);
                  }
                });
              },
            ),

            const SizedBox(height: 30),

            // PRIMARY EMAIL (Required)
            TextField(
              controller: _email1Controller,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Primary Email *",
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                errorText: _email1Controller.text.isEmpty || _isEmail1Valid
                    ? null
                    : "Enter valid email",
              ),
              onChanged: (value) {
                setState(() {
                  _isEmail1Valid = _validateEmail(value);
                });
              },
            ),

            const SizedBox(height: 20),

            // SECONDARY EMAIL (Optional)
            TextField(
              controller: _email2Controller,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Secondary Email (Optional)",
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                errorText: _email2Controller.text.isEmpty || _isEmail2Valid
                    ? null
                    : "Enter valid email",
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _isEmail2Valid = true;
                  } else {
                    _isEmail2Valid = _validateEmail(value);
                  }
                });
              },
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveContacts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Save Contacts",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
