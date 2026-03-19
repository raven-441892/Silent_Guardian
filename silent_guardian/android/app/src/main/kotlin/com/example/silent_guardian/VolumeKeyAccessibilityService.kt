package com.example.silent_guardian

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.os.PowerManager
import android.view.KeyEvent
import android.view.accessibility.AccessibilityEvent
import kotlin.jvm.java

class VolumeKeyAccessibilityService : AccessibilityService() {

    //private val savedSequence = listOf("MAX", "MIN", "MAX")

    private val panicSequence = listOf("MAX", "MIN", "MAX")
    private val fakeCallSequence = listOf("MIN", "MAX", "MIN")
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

        // PANIC TRIGGER
        if (currentInput.takeLast(panicSequence.size) == panicSequence &&
            now - lastTriggerTime >= 5000
        ) {
            lastTriggerTime = now
            currentInput.clear()
            triggerEmergencyPrompt()
            return
        }

        //FAKE CALL TRIGGER
        if (currentInput.takeLast(fakeCallSequence.size) == fakeCallSequence &&
            now - lastTriggerTime >= 3000
        ) {
            lastTriggerTime = now
            currentInput.clear()
            triggerFakeCall()
        }
    }

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
