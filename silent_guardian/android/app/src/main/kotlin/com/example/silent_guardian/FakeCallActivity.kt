package com.example.silent_guardian

import android.app.Activity
import android.graphics.Color
import android.media.MediaPlayer
import android.os.Bundle
import android.view.Gravity
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

class FakeCallActivity : Activity() {

    private var mediaPlayer: MediaPlayer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }

        // 🔊 Play ringtone
        mediaPlayer = MediaPlayer.create(this, android.provider.Settings.System.DEFAULT_RINGTONE_URI)
        mediaPlayer?.isLooping = true
        mediaPlayer?.start()

        val layout = LinearLayout(this)
        layout.orientation = LinearLayout.VERTICAL

        layout.setBackgroundColor(Color.BLACK)
        layout.gravity = Gravity.CENTER

        // Caller name
        val caller = TextView(this)
        caller.text = "Incoming Call"
        caller.setTextColor(Color.WHITE)
        caller.textSize = 24f
        caller.gravity = Gravity.CENTER

        // Number
        val number = TextView(this)
        number.text = "+977 98XXXXXXXX"
        number.setTextColor(Color.LTGRAY)
        number.textSize = 18f
        number.gravity = Gravity.CENTER

        // Accept button
        val acceptBtn = Button(this)
        acceptBtn.text = "Accept"
        acceptBtn.setBackgroundColor(Color.GREEN)

        // Decline button
        val declineBtn = Button(this)
        declineBtn.text = "Decline"
        declineBtn.setBackgroundColor(Color.RED)

        // Button layout
        val btnLayout = LinearLayout(this)
        btnLayout.orientation = LinearLayout.HORIZONTAL
        btnLayout.gravity = Gravity.CENTER
        btnLayout.setPadding(0, 50, 0, 0)

        btnLayout.addView(acceptBtn)
        btnLayout.addView(declineBtn)

        layout.addView(caller)
        layout.addView(number)
        layout.addView(btnLayout)

        setContentView(layout)

        // Button actions
        acceptBtn.setOnClickListener {
            mediaPlayer?.stop()
            showCallConnected()
        }

        declineBtn.setOnClickListener {
            mediaPlayer?.stop()
            finish()
        }
    }

    private fun showCallConnected() {
        val layout = LinearLayout(this)
        layout.orientation = LinearLayout.VERTICAL
        layout.setBackgroundColor(Color.BLACK)
        layout.gravity = Gravity.CENTER

        val text = TextView(this)
        text.text = "Call Connected..."
        text.setTextColor(Color.GREEN)
        text.textSize = 24f

        layout.addView(text)
        setContentView(layout)
    }

    override fun onDestroy() {
        super.onDestroy()
        mediaPlayer?.release()
    }

//        val text = TextView(this)
//        text.text = "Hello"
//        text.setTextColor(Color.GREEN)
//        text.textSize = 30f
//        text.gravity = Gravity.CENTER
//
//        layout.addView(text)
//
//        setContentView(layout)

}