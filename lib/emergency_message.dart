import 'package:flutter/material.dart';
import 'header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyMessageScreen extends StatefulWidget {
  const EmergencyMessageScreen({super.key});

  @override
  State<EmergencyMessageScreen> createState() =>
      _EmergencyMessageScreenState();
}

class _EmergencyMessageScreenState
    extends State<EmergencyMessageScreen> {

      final TextEditingController _messageController =
  TextEditingController();

  bool _isMessageValid = false;

  @override
  void initState() {
    super.initState();
    _loadMessage();
  }

      Future<void> _loadMessage() async {
        final prefs = await SharedPreferences.getInstance();

        String savedMessage = prefs.getString('emergency_message') ?? '';

        setState(() {
          _messageController.text = savedMessage;
          _isMessageValid = savedMessage.trim().isNotEmpty;
        });
      }

      Future<void> _saveMessage() async {
        if (_isMessageValid) {

          final prefs = await SharedPreferences.getInstance();

          await prefs.setString(
              'emergency_message', _messageController.text);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Emergency message saved"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Message cannot be empty"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const AppHeader(enableSignInNavigation: false),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Emergency Message",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),

              TextField(
                controller: _messageController,
                maxLines: 5,
                maxLength: 160,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: "Enter your emergency message *",
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Icon(Icons.message),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                  errorText: _messageController.text.isEmpty || _isMessageValid
                      ? null : "Message cannot be empty",
                  counterText: "${_messageController.text.length}/160",
                ),
                onChanged: (value) =>
                    setState(() => _isMessageValid = value.trim().isNotEmpty),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Save Message",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
