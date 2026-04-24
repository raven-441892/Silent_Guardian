import 'package:shared_preferences/shared_preferences.dart';

class EmergencyService {
  /// Returns a list of all saved phone numbers (primary + optional secondary).
  Future<List<String>> getPhones() async {
    final prefs = await SharedPreferences.getInstance();
    final phones = <String>[];

    final phone1 = prefs.getString('phone1') ?? '';
    final phone2 = prefs.getString('phone2') ?? '';

    if (phone1.isNotEmpty) phones.add(phone1);
    if (phone2.isNotEmpty) phones.add(phone2);

    return phones;
  }

  /// Kept for backwards compatibility — returns the primary phone number.
  Future<String> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone1') ?? '';
  }

  Future<String> getMessage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('emergency_message') ?? 'Help! I am in danger!';
  }
}
