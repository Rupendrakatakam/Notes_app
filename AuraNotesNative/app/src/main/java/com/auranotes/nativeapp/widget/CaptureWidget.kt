package com.auranotes.nativeapp.widget

import android.content.Context
import android.content.Intent
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.glance.Button
import androidx.glance.ButtonColors
import androidx.glance.ButtonDefaults
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.actionStartActivity
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import com.auranotes.nativeapp.MainActivity

class CaptureWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("OPEN_FAST_CAPTURE", true)
            }

            Column(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .background(Color(0xFF1E1E1E))
                    .padding(8.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Button(
                    text = "Quick Capture",
                    onClick = actionStartActivity(intent),
                    colors = ButtonDefaults.buttonColors(
                        backgroundColor = androidx.glance.color.ColorProvider(Color(0xFFD0BCFF)),
                        contentColor = androidx.glance.color.ColorProvider(Color.Black)
                    )
                )
            }
        }
    }
}
