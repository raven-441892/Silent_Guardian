import 'package:shared_preferences/shared_preferences.dart';

// Service to handle emergency data (phones + message)
class EmergencyService {
  // Get all saved phone numbers
  Future<List<String>> getPhones() async {
    final prefs = await SharedPreferences.getInstance();
    final phones = <String>[];

    // Retrieve stored phone numbers
    final phone1 = prefs.getString('phone1') ?? '';
    final phone2 = prefs.getString('phone2') ?? '';

    // Add non-empty numbers to list
    if (phone1.isNotEmpty) phones.add(phone1);
    if (phone2.isNotEmpty) phones.add(phone2);

    return phones;
  }

  //Get primary phone
  Future<String> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone1') ?? '';
  }

  //Get saved emergency message (default if none)
  Future<String> getMessage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('emergency_message') ?? 'Help! I am in danger!';
  }
}
