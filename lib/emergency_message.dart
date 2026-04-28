import 'package:flutter/material.dart';
import 'header.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Message screen widget to add emergency message which gets sent during panic trigger
class EmergencyMessageScreen extends StatefulWidget {
  const EmergencyMessageScreen({super.key});

  @override
  State<EmergencyMessageScreen> createState() =>
      _EmergencyMessageScreenState();
}

class _EmergencyMessageScreenState extends State<EmergencyMessageScreen> {
  // Controller for text input
    final TextEditingController _messageController = TextEditingController();

      // Tracks if message is valid (not empty)
    bool _isMessageValid = false;

  @override
  void initState() {
    super.initState();
    _loadMessage();   // Load saved message on start
  }

    // Load message from local storage
      Future<void> _loadMessage() async {
        final prefs = await SharedPreferences.getInstance();

        String savedMessage = prefs.getString('emergency_message') ?? '';

        setState(() {
          _messageController.text = savedMessage;
          _isMessageValid = savedMessage.trim().isNotEmpty;
        });
      }

    // Save message to local storage
      Future<void> _saveMessage() async {
        if (_isMessageValid) {

          final prefs = await SharedPreferences.getInstance();

          await prefs.setString(
              'emergency_message', _messageController.text);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Emergency message saved"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          //Show error if empty
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
    _messageController.dispose();   // Clean up controller
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
              // Title
              const Text("Emergency Message",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),

              // Warning box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "⚠ Include your name in the message!\n"
                            "Alerts are sent from our app's email address, "
                            "so the receiver will not know who you are unless "
                            "you mention your name.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Message input field
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

                  // Show error if invalid
                  errorText: _messageController.text.isEmpty || _isMessageValid
                      ? null : "Message cannot be empty",

                  // Character counter
                  counterText: "${_messageController.text.length}/160",
                ),

                // Validate on change
                onChanged: (value) =>
                    setState(() => _isMessageValid = value.trim().isNotEmpty),
              ),
              const SizedBox(height: 20),

              // Save button
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
