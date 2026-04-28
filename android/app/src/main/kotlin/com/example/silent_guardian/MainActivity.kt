package com.example.silent_guardian

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

// Main entry point — bridges Flutter and native Android via platform channels
class MainActivity : FlutterActivity() {

    private val ACCESSIBILITY_CHANNEL = "accessibility_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // EventChannel so Flutter can receive "TRIGGER" events when a panic is confirmed.
        // The sink is stored statically so EmergencyPromptActivity can post to it.
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "panic_trigger_channel")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    EmergencyPromptActivity.eventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    EmergencyPromptActivity.eventSink = null
                }
            })

        // MethodChannel for accessibility-related queries from Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ACCESSIBILITY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    //Opens the system Accessibility Settings screen
                    "openAccessibilitySettings" -> {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    }

                    // Checks whether VolumeKeyAccessibilityService is enabled
                    "isAccessibilityEnabled" -> {
                        val expectedService =
                            packageName + "/" + VolumeKeyAccessibilityService::class.java.name

                        val enabledServices = Settings.Secure.getString(
                            contentResolver,
                            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
                        )

                        println("Enabled services: $enabledServices")

                        val isEnabled = enabledServices?.contains(expectedService) == true
                        result.success(isEnabled)
                    }

                    else -> result.notImplemented()
                }
            }
        }
}