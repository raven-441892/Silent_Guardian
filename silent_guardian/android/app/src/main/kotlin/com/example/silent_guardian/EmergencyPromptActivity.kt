package com.example.silent_guardian

import android.app.Activity
import android.graphics.Color
import android.os.Bundle
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast

class EmergencyPromptActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val layout = LinearLayout(this)
        layout.orientation = LinearLayout.VERTICAL
        layout.gravity = Gravity.CENTER
        layout.setBackgroundColor(Color.WHITE)

        val text = TextView(this)
        text.text = "Trigger Emergency?"
        text.textSize = 24f
        text.gravity = Gravity.CENTER
        layout.addView(text)

        val yesBtn = Button(this)
        yesBtn.text = "YES"
        yesBtn.setOnClickListener {
            Toast.makeText(this, "Emergency triggered!", Toast.LENGTH_SHORT).show()
            // TODO: add SMS / backend / notification here
            finish()
        }

        val noBtn = Button(this)
        noBtn.text = "NO"
        noBtn.setOnClickListener {
            finish()
        }

        layout.addView(yesBtn)
        layout.addView(noBtn)

        setContentView(layout)
    }
}