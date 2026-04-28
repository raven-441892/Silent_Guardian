package com.example.silent_guardian

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.os.PowerManager
import android.view.KeyEvent
import android.view.accessibility.AccessibilityEvent
import kotlin.jvm.java

// Accessibility service that intercepts volume key presses to detect secret button sequences
class VolumeKeyAccessibilityService : AccessibilityService() {
    // Panic sequence: Volume Up, Volume Down and Volume Up
    private val panicSequence = listOf("MAX", "MIN", "MAX")

    // Fake call sequence: Volume Down, Volume Up and Volume Down
    private val fakeCallSequence = listOf("MIN", "MAX", "MIN")
    private val currentInput = mutableListOf<String>()

    // Prevents re-triggering within a cooldown window
    private var lastTriggerTime = 0L

    // Intercepts hardware key events; returns true to consume the event (suppresses volume change)
    override fun onKeyEvent(event: KeyEvent): Boolean {
        if (event.action != KeyEvent.ACTION_DOWN) return false

        when (event.keyCode) {
            KeyEvent.KEYCODE_VOLUME_UP -> registerStep("MAX")
            KeyEvent.KEYCODE_VOLUME_DOWN -> registerStep("MIN")
        }
        return true
    }

    // Appends the new step to the buffer and checks if either trigger sequence was just completed
    private fun registerStep(step: String) {
        currentInput.add(step)
        if (currentInput.size > 5) currentInput.removeAt(0)

        val now = System.currentTimeMillis()

        // Check for panic sequence with a 5-second cooldown
        if (currentInput.takeLast(panicSequence.size) == panicSequence &&
            now - lastTriggerTime >= 5000
        ) {
            lastTriggerTime = now
            currentInput.clear()
            triggerEmergencyPrompt()
            return
        }

        // Check for fake-call sequence with a 3-second cooldown
        if (currentInput.takeLast(fakeCallSequence.size) == fakeCallSequence &&
            now - lastTriggerTime >= 3000
        ) {
            lastTriggerTime = now
            currentInput.clear()
            triggerFakeCall()
        }
    }

    //Wakes the device and launches the fake call screen
    private fun triggerFakeCall() {
        wakeDevice()

        val intent = Intent(this, FakeCallActivity::class.java)
        intent.addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
        )

        startActivity(intent)
    }

    //Wakes the device and launches the emergency confirmation prompt
    private fun triggerEmergencyPrompt() {
        wakeDevice()
        val intent = Intent(this, EmergencyPromptActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    // Acquires a brief wake lock to turn the screen on when triggered from a locked state
    private fun wakeDevice() {
        val pm = getSystemService(POWER_SERVICE) as PowerManager
        val wakeLock = pm.newWakeLock(
            PowerManager.FULL_WAKE_LOCK or
                    PowerManager.ACQUIRE_CAUSES_WAKEUP or
                    PowerManager.ON_AFTER_RELEASE,
            "SilentGuardian:WakeLock"
        )
        //Release automatically after 3 seconds
        wakeLock.acquire(3000)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {}
    override fun onInterrupt() {}
}
