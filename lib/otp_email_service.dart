import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/foundation.dart';

// Service to send OTP emails
class OtpEmailService {
  // OTP Sender email credentials (use App Password)
  static const String _senderEmail = 'silentguardian82@gmail.com';
  static const String _appPassword = 'ddrb ejja cbix huck';

  /// Sends a 6-digit [otp] to [recipientEmail].
  /// Returns true on success, false on failure.
  static Future<bool> sendOtp(String recipientEmail, String otp) async {

    // Configure Gmail SMTP
    final smtpServer = gmail(_senderEmail, _appPassword);

    // Build email message
    final message = Message()
      ..from = Address(_senderEmail, 'Silent Guardian')
      ..recipients.add(recipientEmail)
      ..subject = 'Your Silent Guardian OTP'
      ..text = '''Hello,
 
Your one-time verification code is:
 
  $otp
 
This code is valid for 10 minutes. Do not share it with anyone.
 
— Silent Guardian Team''';

    try {
      // Send email
      await send(message, smtpServer);
      debugPrint('[OtpEmailService] OTP email sent to $recipientEmail');
      return true;
    } on MailerException catch (e) {
      // Handle failure
      debugPrint('[OtpEmailService] Failed to send OTP: $e');
      return false;
    }
  }
}