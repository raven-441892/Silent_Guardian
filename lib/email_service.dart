import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {

  Future<void> sendEmail(String recipientEmail, String messageText) async {

    String username = 'silentguardian82@gmail.com';
    String password = 'ddrb ejja cbix huck';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Silent Guardian')
      ..recipients.add(recipientEmail)
      ..subject = 'EMERGENCY ALERT'
      ..text = messageText;

    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent: $sendReport');
    } catch (e) {
      print('Email failed: $e');
      rethrow;
    }
  }
}