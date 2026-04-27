package com.example.silent_guardian

import android.app.Activity
import android.content.Intent
import android.content.res.Resources
import android.graphics.Color
import android.graphics.Typeface
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import io.flutter.plugin.common.EventChannel

class EmergencyPromptActivity : Activity() {

    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    private var secondsLeft = 3
    private lateinit var timerText: TextView
    private var handler = Handler(Looper.getMainLooper())
    private lateinit var runnable: Runnable
    private var alreadyTriggered = false

    private val Int.dp: Int
        get() = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            this.toFloat(),
            Resources.getSystem().displayMetrics
        ).toInt()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.WHITE)
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }

        val header = TextView(this).apply {
            text = "Confirm Emergency"
            setBackgroundColor(Color.parseColor("#2196F3"))
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
            setTypeface(null, Typeface.BOLD)
            setPadding(16.dp, 20.dp, 16.dp, 20.dp)
            gravity = Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        root.addView(header)

        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(24.dp, 0, 24.dp, 0)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                0, 1f
            )
        }

        val questionText = TextView(this).apply {
            text = "Trigger Emergency?"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 22f)
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.parseColor("#212121"))
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).also { it.bottomMargin = 12.dp }
        }

        timerText = TextView(this).apply {
            text = "Auto triggering in $secondsLeft seconds..."
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            setTextColor(Color.parseColor("#D32F2F"))
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).also { it.bottomMargin = 32.dp }
        }

        fun buttonParams() = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            52.dp
        ).also { it.bottomMargin = 12.dp }

        val yesBtn = Button(this).apply {
            text = "YES — TRIGGER NOW"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#D32F2F"))
            layoutParams = buttonParams()
            setOnClickListener { triggerEmergency() }
        }

        val noBtn = Button(this).apply {
            text = "NO — CANCEL"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.parseColor("#212121"))
            setBackgroundColor(Color.parseColor("#E0E0E0"))
            layoutParams = buttonParams()
            setOnClickListener {
                handler.removeCallbacks(runnable)
                finish()
            }
        }

        container.addView(questionText)
        container.addView(timerText)
        container.addView(yesBtn)
        container.addView(noBtn)

        root.addView(container)
        setContentView(root)

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
        if (alreadyTriggered) return
        alreadyTriggered = true
        handler.removeCallbacks(runnable)

        AlertSender.sendAlert(applicationContext)
        eventSink?.success("TRIGGER")

        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        startActivity(intent)
        finish()
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }
}