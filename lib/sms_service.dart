import 'package:telephony/telephony.dart';

class SmsService {
  final Telephony telephony = Telephony.instance;

  Future<bool> requestPermission() async {
    return true;
  }

  Future<void> sendSMS(String phone, String message) async {
    await telephony.sendSms(
      to: phone,
      message: message,
      isMultipart: true,
    );
  }
}