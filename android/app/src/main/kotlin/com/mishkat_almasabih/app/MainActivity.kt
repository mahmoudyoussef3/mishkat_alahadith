package com.mishkat_almasabih.app

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mishkat_almasabih.app/widget"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        // Handle the initial intent when app is launched from widget
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        intent?.let {
            val openScreen = it.getStringExtra("open_screen")
            val fromWidget = it.getBooleanExtra("from_widget", false)
            
            if (fromWidget && openScreen == "hadith_of_the_day") {
                // Send message to Flutter to navigate to Hadith of the Day screen
                methodChannel?.invokeMethod("openHadithOfTheDay", null)
            }
        }
    }
}
