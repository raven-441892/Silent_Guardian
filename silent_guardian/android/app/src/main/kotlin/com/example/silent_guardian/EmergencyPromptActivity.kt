package com.example.silent_guardian

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
class EmergencyPromptActivity : Activity() {

    private var secondsLeft = 3
    private lateinit var timerText: TextView
    private var handler = android.os.Handler()
    private lateinit var runnable: Runnable

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val layout = LinearLayout(this)
        layout.orientation = LinearLayout.VERTICAL
        layout.setBackgroundColor(Color.WHITE)

        // BLUE HEADER
        val header = TextView(this)
        header.text = "Confirm Emergency"
        header.setBackgroundColor(Color.parseColor("#2196F3"))
        header.setTextColor(Color.WHITE)
        header.textSize = 20f
        header.setPadding(30, 40, 30, 40)
        layout.addView(header)

        val container = LinearLayout(this)
        container.orientation = LinearLayout.VERTICAL
        container.gravity = Gravity.CENTER
        container.setPadding(20, 50, 20, 50)

        val text = TextView(this)
        text.text = "Trigger Emergency?"
        text.textSize = 18f
        text.gravity = Gravity.CENTER
        container.addView(text)

        // TIMER TEXT
        timerText = TextView(this)
        timerText.text = "Auto triggering in 3 seconds..."
        timerText.setTextColor(Color.RED)
        timerText.gravity = Gravity.CENTER
        container.addView(timerText)

        val yesBtn = Button(this)
        yesBtn.text = "YES"
        yesBtn.setOnClickListener {
            triggerEmergency()
        }

        val noBtn = Button(this)
        noBtn.text = "NO"
        noBtn.setOnClickListener {
            handler.removeCallbacks(runnable)
            finish()
        }

        container.addView(yesBtn)
        container.addView(noBtn)

        layout.addView(container)
        setContentView(layout)

        startTimer()
    }

    private fun startTimer() {
        runnable = object : Runnable {
            override fun run() {
                secondsLeft--

                if (secondsLeft <= 0) {
                    triggerEmergency()
                } else {
                    timerText.text = "Auto triggering in $secondsLeft seconds..."
                    handler.postDelayed(this, 1000)
                }
            }
        }
        handler.postDelayed(runnable, 1000)
    }

    private fun triggerEmergency() {
        handler.removeCallbacks(runnable)

        // 🔥 IMPORTANT: send event to Flutter
        sendTriggerToFlutter()
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        startActivity(intent)

        finish()
    }

    private fun sendTriggerToFlutter() {
        val intent = Intent("PANIC_TRIGGERED")
        sendBroadcast(intent)
    }
}