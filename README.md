# Silent Guardian
Silent Guardian is an Android safety app built with Flutter that lets users discreetly trigger emergency alerts using hardware button sequences — no need to unlock your phone or open any app.

## Features
### Silent Panic Trigger
Press a secret volume button sequence to instantly send emergency SMS and email alerts to your saved contacts — with your live GPS location attached.

Triggered via Volume Up → Volume Down → Volume Up
A 3-second confirmation screen appears before sending (can be cancelled)
Works even when the phone is locked

### Fake Call
Simulate an incoming phone call to safely exit a threatening situation without suspicion.

Triggered via Volume Down → Volume Up → Volume Down
Displays a realistic incoming call screen with ringtone and vibration
Works over the lock screen

### Location Sharing
Automatically appends a Google Maps link to every emergency alert.

Tries live GPS first, falls back to last known location, then cached coordinates
Location is cached in the background so it's always available even if GPS is slow

### Emergency Contacts
Save up to two phone numbers and two email addresses as emergency contacts.

Required: primary phone + primary email
Optional: secondary phone + secondary email
Input validated before saving

### Custom Emergency Message
Write a personalised emergency message that gets sent with every alert.

Up to 160 characters
Warns you to include your name (alerts are sent from the app's email address)

### Firebase Authentication

Sign up with email + OTP verification
Log in / log out
Guest mode available (no account required)


### Tech Stack
LayerTechnologyFrameworkFlutter (Dart)Native AndroidKotlinAuth & DatabaseFirebase Auth + Cloud FirestoreSMSAndroid SmsManager (native Kotlin) + Telephony pluginEmailJavaMail (android-mail) via Gmail SMTPLocationGeolocator + FusedLocationProviderClientPanic DetectionAndroid Accessibility Service (volume key interception)PreferencesSharedPreferences (Flutter + Kotlin, shared key space)

### Architecture
~~~text
silent_guardian/
├── lib/                        # Flutter (Dart) code
│   ├── main.dart               # App entry point, Firebase init
│   ├── home.dart               # Home screen, emergency trigger logic
│   ├── emergency_contacts.dart # Save/edit emergency contacts
│   ├── emergency_message.dart  # Save/edit emergency message
│   ├── silent_panic_trigger.dart # Instructions screen
│   ├── fake_call_trigger.dart  # Instructions screen
│   ├── sign_in.dart            # Login screen
│   ├── sign_up.dart            # Registration + OTP flow
│   ├── otp_screen.dart         # OTP verification
│   ├── panic_listener.dart     # Listens for native panic events via EventChannel
│   ├── accessibility_helper.dart # MethodChannel bridge for accessibility
│   ├── sms_service.dart        # Flutter-side SMS sending
│   ├── email_service.dart      # Flutter-side email sending
│   ├── emergency_service.dart  # Reads saved contacts from SharedPreferences
│   ├── otp_email_service.dart  # Sends OTP emails
│   ├── responsive.dart         # Responsive sizing helper
│   └── header.dart             # Reusable app bar
│
└── android/app/src/main/kotlin/com/example/silent_guardian/
├── MainActivity.kt             # Flutter entry point, platform channels
├── VolumeKeyAccessibilityService.kt  # Detects volume button sequences
├── EmergencyPromptActivity.kt  # 3-second confirmation screen
├── FakeCallActivity.kt         # Full-screen fake call UI
└── AlertSender.kt              # Native SMS + email sender with GPS
~~~

### How It Works
~~~text
Panic Detection Flow
User presses Vol Up → Vol Down → Vol Up
↓
VolumeKeyAccessibilityService detects sequence
↓
EmergencyPromptActivity launches (3-second countdown)
↓
User confirms (or timer expires)
↓
AlertSender sends SMS + Email with GPS location
↓
EventChannel notifies Flutter → SnackBar shown
Platform Channel Architecture

EventChannel (panic_trigger_channel): Native → Flutter, fires "TRIGGER" on confirmed panic
MethodChannel (accessibility_channel): Flutter → Native, checks/opens accessibility settings
~~~

### Getting Started
Prerequisites

Flutter SDK ≥ 3.10
Android Studio / VS Code
A physical Android device (accessibility services don't work on emulators)
Firebase project with Auth + Firestore enabled

Setup


Clone the repo

Install dependencies

~~~bash
bash   git clone https://github.com/raven-441892/Silent_Guardian.git
cd silent-guardian

bash   flutter pub get
~~~

Firebase setup

Create a Firebase project at console.firebase.google.com
Enable Email/Password authentication
Enable Cloud Firestore
Download google-services.json and place it in android/app/
Update lib/firebase_options.dart with your project's config


Run the app

bash   flutter run

Enable the Accessibility Service

On first launch, the app will prompt you to enable the Silent Guardian Accessibility Service
Go to Settings → Accessibility → Silent Guardian and turn it on
This is required for the panic and fake call triggers to work

## Permissions Required
PermissionPurposeSEND_SMSSend emergency SMS alertsACCESS_FINE_LOCATIONAttach GPS coordinates to alertsACCESS_COARSE_LOCATIONFallback locationREAD_PHONE_STATEDevice telephony infoRECEIVE_SMSListen for SMS (telephony plugin)FOREGROUND_SERVICEKeep services runningMODIFY_AUDIO_SETTINGSVolume key interceptionACCESS_NOTIFICATION_POLICYDND mode awarenessVIBRATEFake call vibrationWAKE_LOCKWake screen on panic triggerBIND_ACCESSIBILITY_SERVICEVolume key detection

## Known Limitations

Android only — iOS is not supported (SMS and accessibility APIs are Android-specific)
The Accessibility Service must be manually enabled by the user in Android Settings
Email is sent via a shared Gmail SMTP account — for production use, replace with your own credentials or a backend service
Fake call caller name and number are hardcoded; customisation is planned


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.

## License
GNU GENERAL PUBLIC LICENSE

## Acknowledgements

- telephony plugin by Shounak Mulay 

- geolocator for location services

- mailer for SMTP email

- Firebase for auth and database