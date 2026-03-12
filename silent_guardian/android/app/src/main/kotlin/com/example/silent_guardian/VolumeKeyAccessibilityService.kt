package com.example.silent_guardian

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.os.PowerManager
import android.view.KeyEvent
import android.view.accessibility.AccessibilityEvent
import kotlin.jvm.java

class VolumeKeyAccessibilityService : AccessibilityService() {

    private val savedSequence = listOf("MAX", "MIN", "MAX")
    private val currentInput = mutableListOf<String>()
    private var lastTriggerTime = 0L

    override fun onKeyEvent(event: KeyEvent): Boolean {
        if (event.action != KeyEvent.ACTION_DOWN) return false

        when (event.keyCode) {
            KeyEvent.KEYCODE_VOLUME_UP -> registerStep("MAX")
            KeyEvent.KEYCODE_VOLUME_DOWN -> registerStep("MIN")
        }
        return true
    }

    private fun registerStep(step: String) {
        currentInput.add(step)
        if (currentInput.size > 5) currentInput.removeAt(0)

        val now = System.currentTimeMillis()
        if (currentInput.takeLast(savedSequence.size) == savedSequence &&
            now - lastTriggerTime >= 5000 // 5s cooldown
        ) {
            lastTriggerTime = now
            currentInput.clear()
            triggerEmergencyPrompt()
        }
    }

    private fun triggerEmergencyPrompt() {
        wakeDevice()
        val intent = Intent(this, EmergencyPromptActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun wakeDevice() {
        val pm = getSystemService(POWER_SERVICE) as PowerManager
        val wakeLock = pm.newWakeLock(
            PowerManager.FULL_WAKE_LOCK or
                    PowerManager.ACQUIRE_CAUSES_WAKEUP or
                    PowerManager.ON_AFTER_RELEASE,
            "SilentGuardian:WakeLock"
        )
        wakeLock.acquire(3000)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {}
    override fun onInterrupt() {}
}

//
//import android.accessibilityservice.AccessibilityService
//import android.view.KeyEvent
//import android.view.accessibility.AccessibilityEvent
//import io.flutter.plugin.common.MethodChannel
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.embedding.engine.dart.DartExecutor
//import android.os.PowerManager
//class VolumeKeyAccessibilityService : AccessibilityService() {
//
//    fun wakeDevice() {
//        val pm = getSystemService(POWER_SERVICE) as PowerManager
//        val wakeLock = pm.newWakeLock(
//            PowerManager.FULL_WAKE_LOCK or
//                    PowerManager.ACQUIRE_CAUSES_WAKEUP or
//                    PowerManager.ON_AFTER_RELEASE,
//            "SilentGuardian:WakeLock"
//        )
//
//        wakeLock.acquire(3000)
//    }
//    companion object {
//        var methodChannel: MethodChannel? = null
//    }
//
//    override fun onServiceConnected() {
//        super.onServiceConnected()
//
//        // Start a Flutter engine in background
//        val flutterEngine = FlutterEngine(this)
//
//        flutterEngine.dartExecutor.executeDartEntrypoint(
//            DartExecutor.DartEntrypoint.createDefault()
//        )
//
//        methodChannel = MethodChannel(
//            flutterEngine.dartExecutor.binaryMessenger,
//            "volume_channel"
//        )
//    }
//
//    override fun onKeyEvent(event: KeyEvent): Boolean {
//
//        if (event.action != KeyEvent.ACTION_DOWN) {
//            return false
//        }
//
//        when (event.keyCode) {
//
//            KeyEvent.KEYCODE_VOLUME_UP -> {
//
//                wakeDevice()
//                methodChannel?.invokeMethod("volumeUp", null)
//            }
//
//            KeyEvent.KEYCODE_VOLUME_DOWN -> {
//
//                wakeDevice()
//                methodChannel?.invokeMethod("volumeDown", null)
//            }
//        }
//
//        return super.onKeyEvent(event)
//    }
//
//    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
//        // Not needed
//    }
//
//    override fun onInterrupt() {
//        // Not needed
//    }
//}
//
