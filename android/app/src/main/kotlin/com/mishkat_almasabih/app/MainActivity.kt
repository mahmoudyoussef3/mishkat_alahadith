package com.mishkat_almasabih.app

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mishkat_almasabih.app/widget"
    private val PRAYER_CHANNEL = "com.mishkat_almasabih.app/prayer_notifications"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Create the prayer notification channel as early as possible so it
        // exists before any alarm fires, even on a fresh install or after a reboot.
        PrayerNotificationScheduler.ensureNotificationChannel(applicationContext)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PRAYER_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "schedulePrayerNotifications" -> {
                        val payload = call.arguments as? String
                        if (payload.isNullOrBlank()) {
                            result.error(
                                "invalid_arguments",
                                "Missing prayer schedule payload",
                                null,
                            )
                            return@setMethodCallHandler
                        }

                        val scheduledCount = PrayerNotificationScheduler.schedulePrayerNotifications(
                            applicationContext,
                            payload,
                        )
                        if (scheduledCount > 0) {
                            result.success(scheduledCount)
                        } else {
                            result.error(
                                "schedule_failed",
                                "No future prayer notification could be scheduled",
                                null,
                            )
                        }
                    }

                    "cancelPrayerNotifications" -> {
                        PrayerNotificationScheduler.cancelPrayerNotifications(applicationContext)
                        result.success(true)
                    }

                    "hasExactAlarmPermission" -> {
                        result.success(
                            PrayerNotificationScheduler.hasExactAlarmPermission(applicationContext),
                        )
                    }

                    "arePrayerNotificationsEnabled" -> {
                        result.success(
                            PrayerNotificationScheduler.arePrayerNotificationsEnabled(
                                applicationContext,
                            ),
                        )
                    }

                    "openPrayerNotificationSettings" -> {
                        try {
                            PrayerNotificationScheduler.openPrayerNotificationSettings(
                                applicationContext,
                            )
                            result.success(true)
                        } catch (exception: Exception) {
                            result.error(
                                "settings_unavailable",
                                "Unable to open prayer notification settings",
                                exception.message,
                            )
                        }
                    }

                    "requestExactAlarmPermission" -> {
                        if (PrayerNotificationScheduler.hasExactAlarmPermission(applicationContext)) {
                            result.success(true)
                        } else {
                            startActivity(
                                PrayerNotificationScheduler.buildExactAlarmPermissionIntent(
                                    applicationContext,
                                ).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) },
                            )
                            result.success(false)
                        }
                    }

                    "hasIgnoreBatteryOptimizations" -> {
                        result.success(
                            PrayerNotificationScheduler.isIgnoringBatteryOptimizations(applicationContext),
                        )
                    }

                    "openBatteryOptimizationSettings" -> {
                        if (PrayerNotificationScheduler.isIgnoringBatteryOptimizations(applicationContext)) {
                            result.success(true)
                        } else {
                            result.success(
                                PrayerNotificationScheduler.openBatteryOptimizationSettings(applicationContext),
                            )
                        }
                    }

                    else -> result.notImplemented()
                }
            }

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

            // Handle widget tap navigation
            if (fromWidget && openScreen == "hadith_of_the_day") {
                methodChannel?.invokeMethod("openHadithOfTheDay", null)
            }

            if (fromWidget && openScreen == "prayer_times") {
                methodChannel?.invokeMethod("openPrayerTimes", null)
            }

            // Link intents (mishkat:// and https) are delivered by the
            // app_links plugin; forwarding them here too would open them twice.
        }
    }
}
