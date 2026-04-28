package com.example.silent_guardian

import android.content.Context
import android.location.Location
import android.os.Build
import android.telephony.SmsManager
import android.util.Log
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.google.android.gms.tasks.CancellationTokenSource
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withTimeout
import java.util.Properties
import javax.mail.Authenticator
import javax.mail.Message
import javax.mail.PasswordAuthentication
import javax.mail.Session
import javax.mail.Transport
import javax.mail.internet.InternetAddress
import javax.mail.internet.MimeMessage
import kotlin.coroutines.resume

// Singleton responsible for sending emergency SMS and email alerts with location
object AlertSender {

    private const val TAG = "AlertSender"

    // Gmail credentials used as the sender for all emergency emails
    private const val SENDER_EMAIL = "silentguardian82@gmail.com"
    private const val SENDER_PASSWORD = "ddrb ejja cbix huck"

    // Entry point: reads saved contacts from SharedPreferences and dispatches alerts
    fun sendAlert(context: Context) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        val phone1  = prefs.getString("flutter.phone1", "") ?: ""
        val phone2  = prefs.getString("flutter.phone2", "") ?: ""
        val email1  = prefs.getString("flutter.email1", "") ?: ""
        val email2  = prefs.getString("flutter.email2", "") ?: ""
        val message = prefs.getString("flutter.emergency_message", "Help! I am in danger!") ?: "Help! I am in danger!"

        // Flutter stores doubles as Strings: read as String, parse to Double
        val cachedLat = prefs.getString("flutter.last_lat", null)?.toDoubleOrNull()
        val cachedLng = prefs.getString("flutter.last_lng", null)?.toDoubleOrNull()

        // Filter out empty entries to get a clean list of recipients
        val phones = listOf(phone1, phone2).filter { it.isNotEmpty() }
        val emails = listOf(email1, email2).filter { it.isNotEmpty() }

        if (phones.isEmpty() && emails.isEmpty()) {
            Log.w(TAG, "No emergency contacts saved — alert aborted")
            return
        }

        // Run network/IO operations off the main thread
        CoroutineScope(Dispatchers.IO).launch {

            // Try fresh GPS; fall back to cached coordinates if unavailable
            val locationString = getFreshLocation(context)
                ?: if (cachedLat != null && cachedLng != null)
                    "https://maps.google.com/?q=$cachedLat,$cachedLng"
                else null

            // Append Google Maps link to the message if location is available
            val fullMessage = if (locationString != null)
                "$message\n\nMy location: $locationString"
            else
                message

            // Send SMS to each phone number
            for (phone in phones) {
                try {
                    sendSms(context, phone, fullMessage)
                    Log.d(TAG, "SMS sent to $phone")
                } catch (e: Exception) {
                    Log.e(TAG, "SMS failed to $phone: ${e.message}")
                }
            }

            // Send email to each address
            for (email in emails) {
                try {
                    sendEmail(email, fullMessage)
                    Log.d(TAG, "Email sent to $email")
                } catch (e: Exception) {
                    Log.e(TAG, "Email failed to $email: ${e.message}")
                }
            }
        }
    }

    // Attempts to get a fresh GPS fix within 4 seconds; updates the cache on success
    private suspend fun getFreshLocation(context: Context): String? {
        return try {
            withTimeout(4_000L) {
                suspendCancellableCoroutine { cont ->
                    val client = LocationServices.getFusedLocationProviderClient(context)
                    val cts = CancellationTokenSource()
                    cont.invokeOnCancellation { cts.cancel() }
                    try {
                        client.getCurrentLocation(Priority.PRIORITY_BALANCED_POWER_ACCURACY, cts.token)
                            .addOnSuccessListener { loc: Location? ->
                                if (loc != null) {
                                    // Store as String to match Flutter's shared_preferences format
                                    context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                                        .edit()
                                        .putString("flutter.last_lat", loc.latitude.toString())
                                        .putString("flutter.last_lng", loc.longitude.toString())
                                        .apply()
                                    cont.resume("https://maps.google.com/?q=${loc.latitude},${loc.longitude}")
                                } else {
                                    cont.resume(null)
                                }
                            }
                            .addOnFailureListener { cont.resume(null) }
                    } catch (e: SecurityException) {
                        cont.resume(null)
                    }
                }
            }
        } catch (e: Exception) {
            Log.d(TAG, "Fresh location unavailable: ${e.message}")
            null
        }
    }

    // Sends an SMS, splitting into multipart if the message exceeds one segment
    private fun sendSms(context: Context, phone: String, message: String) {
        val smsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            context.getSystemService(SmsManager::class.java)
        } else {
            @Suppress("DEPRECATION")
            SmsManager.getDefault()
        }
        val parts = smsManager.divideMessage(message)
        if (parts.size == 1) {
            smsManager.sendTextMessage(phone, null, message, null, null)
        } else {
            smsManager.sendMultipartTextMessage(phone, null, parts, null, null)
        }
    }

    // Sends an email via Gmail SMTP using STARTTLS on port 587
    private fun sendEmail(recipient: String, messageText: String) {
        val props = Properties().apply {
            put("mail.smtp.auth", "true")
            put("mail.smtp.starttls.enable", "true")
            put("mail.smtp.host", "smtp.gmail.com")
            put("mail.smtp.port", "587")
            put("mail.smtp.ssl.trust", "smtp.gmail.com")
        }

        val session = Session.getInstance(props, object : Authenticator() {
            override fun getPasswordAuthentication() =
                PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD)
        })

        val mimeMessage = MimeMessage(session).apply {
            setFrom(InternetAddress(SENDER_EMAIL, "Silent Guardian"))
            addRecipient(Message.RecipientType.TO, InternetAddress(recipient))
            subject = "EMERGENCY ALERT"
            setText(messageText)
        }

        Transport.send(mimeMessage)
    }
}