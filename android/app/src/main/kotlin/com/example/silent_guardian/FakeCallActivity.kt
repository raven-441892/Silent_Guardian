package com.example.silent_guardian

import android.app.Activity
import android.content.Context
import android.content.res.Resources
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.TypedValue
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
// Activity that simulates an incoming phone call to help users escape unsafe situations
class FakeCallActivity : Activity() {
    private var mediaPlayer: MediaPlayer? = null

    // Converts dp to pixels using current display metrics
    private val Int.dp: Int
        get() = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            this.toFloat(),
            Resources.getSystem().displayMetrics
        ).toInt()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)


        // Show over the lock screen so the fake call appears even when the phone is locked
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }

        // Hide status bar and navigation for a full-screen call UI
        window.decorView.systemUiVisibility =
            View.SYSTEM_UI_FLAG_FULLSCREEN or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION

        // Play the device's default ringtone on loop
        mediaPlayer = MediaPlayer.create(this, android.provider.Settings.System.DEFAULT_RINGTONE_URI)
        mediaPlayer?.isLooping = true
        mediaPlayer?.start()

        startVibration()

        actionBar?.hide()

        // Root black layout matching a real incoming-call screen
        val root = LinearLayout(this)
        root.orientation = LinearLayout.VERTICAL
        root.setBackgroundColor(Color.BLACK)
        root.layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.MATCH_PARENT
        )

        // Top section: caller name and number
        val topSection = LinearLayout(this)
        topSection.orientation = LinearLayout.VERTICAL
        topSection.gravity = Gravity.CENTER
        topSection.setPadding(16.dp, 0, 16.dp, 0)
        topSection.layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            0, 1f
        )

        val incoming = TextView(this)
        incoming.text = "Incoming call..."
        incoming.setTextColor(Color.GRAY)
        incoming.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
        incoming.gravity = Gravity.CENTER
        val incomingParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        )
        incomingParams.bottomMargin = 8.dp
        incoming.layoutParams = incomingParams

        //Fake caller name displayed on screen
        val caller = TextView(this)
        caller.text = "Mom"
        caller.setTextColor(Color.WHITE)
        caller.setTextSize(TypedValue.COMPLEX_UNIT_SP, 34f)
        caller.gravity = Gravity.CENTER
        val callerParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        )
        callerParams.bottomMargin = 8.dp
        caller.layoutParams = callerParams

        //fake phone number displayed below caller name
        val number = TextView(this)
        number.text = "+977 9841287965"
        number.setTextColor(Color.LTGRAY)
        number.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
        number.gravity = Gravity.CENTER
        number.layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        )

        topSection.addView(incoming)
        topSection.addView(caller)
        topSection.addView(number)

        //Bottom section: decline (red) and accept (green) circular buttons
        val bottomSection = LinearLayout(this)
        bottomSection.orientation = LinearLayout.HORIZONTAL
        bottomSection.gravity = Gravity.CENTER
        bottomSection.setPadding(0, 0, 0, 32.dp)
        bottomSection.layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            0, 1f
        )

        val btnSize = 72.dp

        // Decline button — rotated phone emoji on a red circle
        val declineBtn = Button(this)
        declineBtn.text = "\uD83D\uDCDE"
        declineBtn.rotation = 135f
        declineBtn.setTextSize(TypedValue.COMPLEX_UNIT_SP, 28f)
        declineBtn.setTextColor(Color.WHITE)
        declineBtn.background = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(Color.parseColor("#D32F2F"))
        }
        val declineParams = LinearLayout.LayoutParams(btnSize, btnSize)
        declineParams.setMargins(24.dp, 0, 24.dp, 0)
        declineBtn.layoutParams = declineParams

        // Accept button: phone emoji on a green circle
        val acceptBtn = Button(this)
        acceptBtn.text = "\uD83D\uDCDE"
        acceptBtn.setTextSize(TypedValue.COMPLEX_UNIT_SP, 28f)
        acceptBtn.setTextColor(Color.WHITE)
        acceptBtn.background = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(Color.parseColor("#388E3C"))
        }
        val acceptParams = LinearLayout.LayoutParams(btnSize, btnSize)
        acceptParams.setMargins(24.dp, 0, 24.dp, 0)
        acceptBtn.layoutParams = acceptParams

        bottomSection.addView(declineBtn)
        bottomSection.addView(acceptBtn)

        root.addView(topSection)
        root.addView(bottomSection)

        setContentView(root)

        //Accept: stop ringtone/vibration and show connected screen
        acceptBtn.setOnClickListener {
            mediaPlayer?.stop()
            stopVibration()
            showCallConnected()
        }

        //Decline: stop ringtone/vibration and close the activity
        declineBtn.setOnClickListener {
            mediaPlayer?.stop()
            stopVibration()
            finish()
        }
    }

    // Returns the correct Vibrator instance for the current API level
    private fun getVibrator(): Vibrator {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vm = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vm.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
    }

    // Vibrates in a repeating 500ms on / 500ms off pattern to mimic a ringing phone
    private fun startVibration() {
        val vibrator = getVibrator()
        val pattern = longArrayOf(0, 500, 500)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createWaveform(pattern, 0))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(pattern, 0)
        }
    }

    private fun stopVibration() {
        getVibrator().cancel()
    }

    // Replaces the call UI with a simple "Call Connected..." message
    private fun showCallConnected() {
        val layout = LinearLayout(this)
        layout.orientation = LinearLayout.VERTICAL
        layout.setBackgroundColor(Color.BLACK)
        layout.gravity = Gravity.CENTER

        val text = TextView(this)
        text.text = "Call Connected..."
        text.setTextColor(Color.GREEN)
        text.setTextSize(TypedValue.COMPLEX_UNIT_SP, 24f)

        layout.addView(text)
        setContentView(layout)
    }

    override fun onDestroy() {
        stopVibration()
        mediaPlayer?.release()
        super.onDestroy()
    }

    // Suppress volume key events so the user can't accidentally change volume during the fake call
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        return if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN ||
            keyCode == KeyEvent.KEYCODE_VOLUME_UP
        ) true
        else super.onKeyDown(keyCode, event)
    }
}