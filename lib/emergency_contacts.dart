import 'package:flutter/material.dart';
import 'package:silent_guardian/responsive.dart';
import 'header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends State<EmergencyContactsScreen> {
      @override
      void initState() {
        super.initState();
        _loadContacts();
      }

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

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _phone1Controller.text = prefs.getString('phone1') ?? '';
      _phone2Controller.text = prefs.getString('phone2') ?? '';
      _email1Controller.text = prefs.getString('email1') ?? '';
      _email2Controller.text = prefs.getString('email2') ?? '';

      _isPhone1Valid = _validatePhone(_phone1Controller.text);
      _isPhone2Valid = _phone2Controller.text.isEmpty ||
          _validatePhone(_phone2Controller.text);

      _isEmail1Valid = _validateEmail(_email1Controller.text);
      _isEmail2Valid = _email2Controller.text.isEmpty ||
          _validateEmail(_email2Controller.text);
    });
  }

  Future<void> _saveContacts() async {
    if (_isPhone1Valid && _isEmail1Valid && _isPhone2Valid && _isEmail2Valid) {

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('phone1', _phone1Controller.text);
      await prefs.setString('phone2', _phone2Controller.text);
      await prefs.setString('email1', _email1Controller.text);
      await prefs.setString('email2', _email2Controller.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Emergency contacts saved"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in fields properly before saving"),
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
              Text("Emergency Contacts",
                  style: TextStyle(fontSize: R.fontTitle, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              SizedBox(height: R.spacingMedium),

              TextField(
                controller: _phone1Controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Primary Phone Number *",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.radius)),
                  filled: true, fillColor: Colors.white,
                  errorText: _phone1Controller.text.isEmpty || _isPhone1Valid
                      ? null : "Enter valid phone number (7-15 digits)",
                ),
                onChanged: (value) => setState(() => _isPhone1Valid = _validatePhone(value)),
              ),
              SizedBox(height: R.spacingSmall),

              TextField(
                controller: _phone2Controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Secondary Phone (Optional)",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.radius)),
                  filled: true, fillColor: Colors.white,
                  errorText: _phone2Controller.text.isEmpty || _isPhone2Valid
                      ? null : "Enter valid phone number",
                ),
                onChanged: (value) => setState(() =>
                _isPhone2Valid = value.isEmpty ? true : _validatePhone(value)),
              ),
              SizedBox(height: R.spacingSmall),

              TextField(
                controller: _email1Controller,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Primary Email *",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.radius)),
                  filled: true, fillColor: Colors.white,
                  errorText: _email1Controller.text.isEmpty || _isEmail1Valid
                      ? null : "Enter valid email",
                ),
                onChanged: (value) => setState(() => _isEmail1Valid = _validateEmail(value)),
              ),
              SizedBox(height: R.spacingSmall),

              TextField(
                controller: _email2Controller,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Secondary Email (Optional)",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.radius)),
                  filled: true, fillColor: Colors.white,
                  errorText: _email2Controller.text.isEmpty || _isEmail2Valid
                      ? null : "Enter valid email",
                ),
                onChanged: (value) => setState(() =>
                _isEmail2Valid = value.isEmpty ? true : _validateEmail(value)),
              ),
              SizedBox(height: R.spacingLarge),

              SizedBox(
                height: R.buttonHeight,
                child: ElevatedButton(
                  onPressed: _saveContacts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.radius)),
                  ),
                  child: Text("Save Contacts",
                      style: TextStyle(fontSize: R.fontMedium, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              SizedBox(height: R.spacingSmall),
            ],
          ),
        ),
      ),
    );
  }
}
