import 'package:telephony/telephony.dart';

class SmsService {
  // Telephony instance for sending SMS
  final Telephony telephony = Telephony.instance;

  // Request SMS permission
  Future<bool> requestPermission() async {
    return true;
  }

  // Sends SMS to a given phone number
  Future<void> sendSMS(String phone, String message) async {
    await telephony.sendSms(
      to: phone,
      message: message,
      isMultipart: true,  // supports long messages
    );
  }
}