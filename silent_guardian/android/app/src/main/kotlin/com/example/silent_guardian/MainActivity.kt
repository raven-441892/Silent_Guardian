package com.example.silent_guardian

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "accessibility_channel"
    private val PANIC_CHANNEL = "panic_trigger_channel"
    private var eventSink: EventChannel.EventSink? = null
    private var pendingTrigger: Boolean = false

    private val panicReceiver = object : android.content.BroadcastReceiver() {
        override fun onReceive(context: android.content.Context?, intent: Intent?) {
            if (intent?.action == "PANIC_TRIGGERED") {
                if (eventSink != null) {
                    eventSink?.success("TRIGGER")
                } else {
                    pendingTrigger = true
                }
            }
        }
    }

    override fun onStart() {
        super.onStart()

        val filter = android.content.IntentFilter("PANIC_TRIGGERED")

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(
                panicReceiver,
                filter,
                android.content.Context.RECEIVER_NOT_EXPORTED
            )
        } else {
            registerReceiverLegacy(panicReceiver, filter)
        }
    }

    @Suppress("DEPRECATION")
    private fun registerReceiverLegacy(
        receiver: android.content.BroadcastReceiver,
        filter: android.content.IntentFilter
    ) {
        registerReceiver(receiver, filter)
    }

    override fun onStop() {
        super.onStop()
        try {
            unregisterReceiver(panicReceiver)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 🔥 PANIC CHANNEL
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, PANIC_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events

                    if (pendingTrigger) {
                        eventSink?.success("TRIGGER")
                        pendingTrigger = false
                    }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })


        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                when (call.method) {

                    "openAccessibilitySettings" -> {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    }

                    "isAccessibilityEnabled" -> {

                        val expectedService =
                            packageName + "/" + VolumeKeyAccessibilityService::class.java.name

                        val enabledServices = Settings.Secure.getString(
                            contentResolver,
                            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
                        )

                        println("Enabled services: $enabledServices")

                        val accessibilityEnabled =
                            enabledServices?.contains(expectedService) == true

                        result.success(accessibilityEnabled)
                    }

                    else -> result.notImplemented()
                }
            }
    }
}