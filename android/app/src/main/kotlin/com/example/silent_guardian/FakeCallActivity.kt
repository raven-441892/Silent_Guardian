package com.example.silent_guardian

import android.app.Activity
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.media.MediaPlayer
import android.os.Bundle
import android.os.Vibrator
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
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

        window.decorView.systemUiVisibility =
            View.SYSTEM_UI_FLAG_FULLSCREEN or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION

        //Play ringtone
        mediaPlayer = MediaPlayer.create(this, android.provider.Settings.System.DEFAULT_RINGTONE_URI)
        mediaPlayer?.isLooping = true
        mediaPlayer?.start()

        actionBar?.hide()

        //Vibration
//        vibrator = getSystemService(VIBRATOR_SERVICE) as Vibrator
//        vibrator?.vibrate(1000)

        //ROOT LAYOUT
        val root = LinearLayout(this)
        root.orientation = LinearLayout.VERTICAL
        root.setBackgroundColor(Color.BLACK)
        root.layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.MATCH_PARENT
        )

        //TOP SECTION
        val topSection = LinearLayout(this)
        topSection.orientation = LinearLayout.VERTICAL
        topSection.gravity = Gravity.CENTER
        topSection.layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            0,
            1f
        )

        val incoming = TextView(this)
        incoming.text = "Incoming call..."
        incoming.setTextColor(Color.GRAY)
        incoming.textSize = 18f
        incoming.gravity = Gravity.CENTER

        val caller = TextView(this)
        caller.text = "Mom"
        caller.setTextColor(Color.WHITE)
        caller.textSize = 32f
        caller.gravity = Gravity.CENTER

        val number = TextView(this)
        number.text = "+977 9841287965"
        number.setTextColor(Color.LTGRAY)
        number.textSize = 20f
        number.gravity = Gravity.CENTER

        topSection.addView(incoming)
        topSection.addView(caller)
        topSection.addView(number)

        //BOTTOM SECTION
        val bottomSection = LinearLayout(this)
        bottomSection.orientation = LinearLayout.HORIZONTAL
        bottomSection.gravity = Gravity.CENTER
        bottomSection.layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            0,
            1f
        )

        //DECLINE BUTTON
        val declineBtn = Button(this)
        declineBtn.text =  "\uD83D\uDCDE"
        declineBtn.rotation = 135f
        declineBtn.textSize = 36f
        declineBtn.setTextColor(Color.WHITE)

        // Create circular background
        val circleDrawable = GradientDrawable()
        circleDrawable.shape = GradientDrawable.OVAL // makes it circular
        circleDrawable.setColor(Color.parseColor("#D32F2F")) // red color

        declineBtn.background = circleDrawable

        // Set size
        val declineParams = LinearLayout.LayoutParams(135, 135)
        declineParams.setMargins(100, 0, 100, 0)
        declineBtn.layoutParams = declineParams

        //ACCEPT BUTTON
        val acceptBtn = Button(this)
        acceptBtn.text = "\uD83D\uDCDE"
        acceptBtn.textSize = 36f
        acceptBtn.setTextColor(Color.WHITE)

        val acceptDrawable = GradientDrawable()
        acceptDrawable.shape = GradientDrawable.OVAL
        acceptDrawable.setColor(Color.parseColor("#388E3C")) // green

        acceptBtn.background = acceptDrawable

        val acceptParams = LinearLayout.LayoutParams(135, 135)
        acceptParams.setMargins(100, 0, 100, 0)
        acceptBtn.layoutParams = acceptParams

        bottomSection.addView(declineBtn)
        bottomSection.addView(acceptBtn)

        root.addView(topSection)
        root.addView(bottomSection)

        setContentView(root)

        // 🎯 BUTTON ACTIONS
        acceptBtn.setOnClickListener {
            mediaPlayer?.stop()
            showCallConnected()
        }

        declineBtn.setOnClickListener {
            mediaPlayer?.stop()
            finish()
        }
    }

    //AFTER ACCEPT
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

    // 🔊 Disable volume buttons during fake call (optional realism)
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        return if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN ||
            keyCode == KeyEvent.KEYCODE_VOLUME_UP
        ) {
            true
        } else {
            super.onKeyDown(keyCode, event)
        }
    }
}
//
//    private fun showCallConnected() {
//        val layout = LinearLayout(this)
//        layout.orientation = LinearLayout.VERTICAL
//        layout.setBackgroundColor(Color.BLACK)
//        layout.gravity = Gravity.CENTER
//
//        val text = TextView(this)
//        text.text = "Call Connected..."
//        text.setTextColor(Color.GREEN)
//        text.textSize = 24f
//
//        layout.addView(text)
//        setContentView(layout)
//    }
//
//    override fun onDestroy() {
//        super.onDestroy()
//        mediaPlayer?.release()
//    }

//        val text = TextView(this)
//        text.text = "Hello"
//        text.setTextColor(Color.GREEN)
//        text.textSize = 30f
//        text.gravity = Gravity.CENTER
//
//        layout.addView(text)
//
//        setContentView(layout)

