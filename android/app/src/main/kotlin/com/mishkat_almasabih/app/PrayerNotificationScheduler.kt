package com.mishkat_almasabih.app

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

data class PrayerNotificationEntry(
    val id: Int,
    val prayerKey: String,
    val prayerLabel: String,
    val title: String,
    val body: String,
    val fireAtMillis: Long,
)

object PrayerNotificationScheduler {
    private const val TAG = "PrayerNotification"
    private const val PREFS_NAME = "prayer_notification_scheduler"
    private const val KEY_SCHEDULES = "schedules_json"
    private const val KEY_ROLLING_SCHEDULER_MIGRATED = "rolling_scheduler_migrated"
    private const val CHANNEL_ID = "prayer_notifications"
    private const val CHANNEL_NAME = "Prayer Time Notifications"
    private const val CHANNEL_DESCRIPTION = "Exact prayer time reminders"
    // Brand purple used to tint the notification's small icon and app name.
    private val BRAND_ACCENT_COLOR = Color.parseColor("#7440E9")
    const val EXTRA_NOTIFICATION_ID = "extra_notification_id"
    const val EXTRA_PRAYER_KEY = "extra_prayer_key"
    const val EXTRA_PRAYER_LABEL = "extra_prayer_label"
    const val EXTRA_TITLE = "extra_title"
    const val EXTRA_BODY = "extra_body"
    const val EXTRA_FIRE_AT_MILLIS = "extra_fire_at_millis"
    private const val ACTION_FIRE = "com.mishkat_almasabih.app.action.PRAYER_NOTIFICATION"

    fun schedulePrayerNotifications(context: Context, payload: String): Int {
        val entries = parseEntries(payload)
        Log.d(TAG, "schedulePrayerNotifications: parsed ${entries.size} entries")
        return replaceSchedules(context, entries)
    }

    fun restorePrayerNotifications(context: Context) {
        val entries = loadEntries(context)
        if (entries.isEmpty()) {
            Log.d(TAG, "restorePrayerNotifications: no stored entries to restore")
            return
        }

        val now = System.currentTimeMillis()
        val futureEntries = entries.filter { it.fireAtMillis > now }
        Log.d(TAG, "restorePrayerNotifications: restoring ${futureEntries.size} of ${entries.size} entries")
        persistEntries(context, futureEntries)
        scheduleNextEntry(context, futureEntries)
    }

    fun cancelPrayerNotifications(context: Context) {
        val entries = loadEntries(context)
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val prefs = getPrefs(context)
        val entriesToCancel =
            if (prefs.getBoolean(KEY_ROLLING_SCHEDULER_MIGRATED, false)) {
                listOfNotNull(entries.minByOrNull { it.fireAtMillis })
            } else {
                // One-time cleanup for upgrades from versions that scheduled every
                // stored prayer as a separate system alarm.
                entries
            }

        entriesToCancel.forEach { entry ->
            alarmManager.cancel(buildPendingIntent(context, entry))
        }

        prefs.edit().putBoolean(KEY_ROLLING_SCHEDULER_MIGRATED, true).apply()
        persistEntries(context, emptyList())
        Log.d(TAG, "cancelPrayerNotifications: cancelled ${entriesToCancel.size} alarms")
    }

    fun onPrayerNotificationFired(context: Context, notificationId: Int) {
        val now = System.currentTimeMillis()
        val remaining = loadEntries(context).filter {
            it.id != notificationId && it.fireAtMillis > now
        }
        persistEntries(context, remaining)
        scheduleNextEntry(context, remaining)
    }

    fun hasExactAlarmPermission(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }
    }

    fun requestExactAlarmPermission(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return true
        }

        return try {
            val intent = buildExactAlarmPermissionIntent(context).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Unable to request exact alarm permission", e)
            false
        }
    }

    fun buildExactAlarmPermissionIntent(context: Context): Intent {
        return Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
            data = android.net.Uri.parse("package:${context.packageName}")
        }
    }

    // Called from MainActivity.configureFlutterEngine so the channel exists
    // before any alarm fires (even after a fresh install or reboot).
    fun ensureNotificationChannel(context: Context) {
        createChannel(context)
    }

    fun arePrayerNotificationsEnabled(context: Context): Boolean {
        if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) {
            return false
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channel = notificationManager.getNotificationChannel(CHANNEL_ID)
            return channel == null || channel.importance != NotificationManager.IMPORTANCE_NONE
        }

        return true
    }

    fun openPrayerNotificationSettings(context: Context) {
        val intent =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Intent(Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
                    putExtra(Settings.EXTRA_CHANNEL_ID, CHANNEL_ID)
                }
            } else {
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = android.net.Uri.parse("package:${context.packageName}")
                }
            }
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }

    fun showPrayerNotification(context: Context, entry: PrayerNotificationEntry) {
        try {
            createChannel(context)

            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            if (!arePrayerNotificationsEnabled(context)) {
                Log.w(TAG, "showPrayerNotification: notifications disabled by user — skipping ${entry.prayerKey}")
                return
            }

            val prayerLabel = entry.prayerLabel.ifBlank { prayerLabelFromKey(entry.prayerKey) }
            val reminderTime = formatReminderTime(entry.fireAtMillis)
            val reminderTitle = "صلاة $prayerLabel"
            val reminderSubtitle = "حان الآن موعد الأذان"
            // Fallback text used by the collapsed/system rendering and for
            // accessibility services when the custom view can't be shown.
            val reminderContentText = "حان الآن موعد صلاة $prayerLabel — $reminderTime"

            val contentIntent = PendingIntent.getActivity(
                context,
                entry.id,
                Intent(context, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                },
                pendingIntentFlags(),
            )

            val openAction = NotificationCompat.Action.Builder(
                0,
                "فتح التطبيق",
                contentIntent,
            ).build()

            // Separate layouts per state: Android 12+ caps the collapsed custom
            // view at 48dp, which clipped the old shared layout. Only set ids that
            // exist in each layout, or SystemUI fails to inflate the notification.
            val collapsedView = RemoteViews(context.packageName, R.layout.notification_prayer_collapsed).apply {
                setTextViewText(R.id.notification_title, reminderTitle)
                setTextViewText(R.id.notification_time, reminderTime)
            }
            val expandedView = RemoteViews(context.packageName, R.layout.notification_prayer_expanded).apply {
                setTextViewText(R.id.notification_title, reminderTitle)
                setTextViewText(R.id.notification_subtitle, reminderSubtitle)
                setTextViewText(R.id.notification_time, reminderTime)
            }

            val notification = NotificationCompat.Builder(context, CHANNEL_ID)
                // MUST be a drawable resource, not a mipmap.
                // Android 8+ ignores color and uses only the alpha channel.
                .setSmallIcon(R.drawable.ic_notification)
                // Tints the small icon and app name in the decorated header to
                // match the brand purple used by the custom card below.
                .setColor(BRAND_ACCENT_COLOR)
                .setStyle(NotificationCompat.DecoratedCustomViewStyle())
                .setCustomContentView(collapsedView)
                .setCustomBigContentView(expandedView)
                .setContentTitle(reminderTitle)
                .setContentText(reminderContentText)
                .setWhen(entry.fireAtMillis)
                .setShowWhen(true)
                .setContentIntent(contentIntent)
                .addAction(openAction)
                .setAutoCancel(true)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setDefaults(NotificationCompat.DEFAULT_SOUND or NotificationCompat.DEFAULT_VIBRATE)
                .build()

            notificationManager.notify(entry.id, notification)
            Log.d(TAG, "showPrayerNotification: posted notification id=${entry.id} for ${entry.prayerKey} at $reminderTime")
        } catch (e: Exception) {
            Log.e(TAG, "showPrayerNotification: failed for prayer=${entry.prayerKey} id=${entry.id}", e)
        }
    }

    private fun replaceSchedules(
        context: Context,
        entries: List<PrayerNotificationEntry>,
    ): Int {
        cancelPrayerNotifications(context)

        val now = System.currentTimeMillis()
        val futureEntries = entries.filter { it.fireAtMillis > now }

        persistEntries(context, futureEntries)
        val scheduled = scheduleNextEntry(context, futureEntries)
        Log.d(TAG, "replaceSchedules: stored ${futureEntries.size} reminders and scheduled next=$scheduled (${entries.size - futureEntries.size} past entries ignored)")
        return if (scheduled) futureEntries.size else 0
    }

    private fun scheduleNextEntry(
        context: Context,
        entries: List<PrayerNotificationEntry> = loadEntries(context),
    ): Boolean {
        val now = System.currentTimeMillis()
        val nextEntry = entries
            .asSequence()
            .filter { it.fireAtMillis > now }
            .minByOrNull { it.fireAtMillis }
            ?: return false

        return scheduleEntry(context, nextEntry)
    }

    private fun scheduleEntry(context: Context, entry: PrayerNotificationEntry): Boolean {
        if (entry.fireAtMillis <= System.currentTimeMillis()) return false

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pendingIntent = buildPendingIntent(context, entry)

        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmManager.canScheduleExactAlarms()) {
                Log.w(TAG, "scheduleEntry: exact alarm permission not granted — using inexact alarm for ${entry.prayerKey} at ${formatReminderTime(entry.fireAtMillis)}")
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    entry.fireAtMillis,
                    pendingIntent,
                )
            } else {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    entry.fireAtMillis,
                    pendingIntent,
                )
                Log.d(TAG, "scheduleEntry: exact alarm set for ${entry.prayerKey} at ${formatReminderTime(entry.fireAtMillis)} (id=${entry.id})")
            }
            true
        } catch (e: SecurityException) {
            // Exact alarm permission was revoked between the canScheduleExactAlarms() check
            // and setExactAndAllowWhileIdle(). Fall back to inexact.
            Log.w(TAG, "scheduleEntry: SecurityException — falling back to inexact alarm for ${entry.prayerKey}", e)
            try {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    entry.fireAtMillis,
                    pendingIntent,
                )
                true
            } catch (e2: Exception) {
                Log.e(TAG, "scheduleEntry: fallback alarm also failed for ${entry.prayerKey}", e2)
                false
            }
        } catch (e: Exception) {
            Log.e(TAG, "scheduleEntry: unexpected error for ${entry.prayerKey}", e)
            false
        }
    }

    private fun buildPendingIntent(context: Context, entry: PrayerNotificationEntry): PendingIntent {
        val intent = Intent(context, PrayerNotificationReceiver::class.java).apply {
            action = ACTION_FIRE
            putExtra(EXTRA_NOTIFICATION_ID, entry.id)
            putExtra(EXTRA_PRAYER_KEY, entry.prayerKey)
            putExtra(EXTRA_PRAYER_LABEL, entry.prayerLabel)
            putExtra(EXTRA_TITLE, entry.title)
            putExtra(EXTRA_BODY, entry.body)
            putExtra(EXTRA_FIRE_AT_MILLIS, entry.fireAtMillis)
        }

        return PendingIntent.getBroadcast(
            context,
            entry.id,
            intent,
            pendingIntentFlags(),
        )
    }

    private fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Only create if not already present — createNotificationChannel is idempotent
        // but we skip the work entirely to avoid unnecessary object allocation on every alarm.
        if (notificationManager.getNotificationChannel(CHANNEL_ID) != null) return

        val soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = CHANNEL_DESCRIPTION
            enableVibration(true)
            setSound(soundUri, audioAttributes)
        }

        notificationManager.createNotificationChannel(channel)
        Log.d(TAG, "createChannel: notification channel '$CHANNEL_ID' created")
    }

    private fun persistEntries(context: Context, entries: List<PrayerNotificationEntry>) {
        val prefs = getPrefs(context)
        val json = JSONArray()
        entries.forEach { entry ->
            val item = JSONObject()
                .put("id", entry.id)
                .put("prayerKey", entry.prayerKey)
                .put("prayerLabel", entry.prayerLabel)
                .put("title", entry.title)
                .put("body", entry.body)
                .put("fireAtMillis", entry.fireAtMillis)
            json.put(item)
        }
        prefs.edit().putString(KEY_SCHEDULES, json.toString()).apply()
    }

    private fun loadEntries(context: Context): List<PrayerNotificationEntry> {
        val raw = getPrefs(context).getString(KEY_SCHEDULES, null) ?: return emptyList()

        return try {
            val array = JSONArray(raw)
            buildList {
                for (index in 0 until array.length()) {
                    val item = array.getJSONObject(index)
                    add(
                        PrayerNotificationEntry(
                            id = item.getInt("id"),
                            prayerKey = item.getString("prayerKey"),
                            prayerLabel = item.optString("prayerLabel", ""),
                            title = item.getString("title"),
                            body = item.getString("body"),
                            fireAtMillis = item.getLong("fireAtMillis"),
                        ),
                    )
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "loadEntries: failed to deserialize stored entries", e)
            emptyList()
        }
    }

    private fun parseEntries(payload: String): List<PrayerNotificationEntry> {
        return try {
            val root = JSONObject(payload)
            val items = root.optJSONArray("items") ?: JSONArray()
            buildList {
                for (index in 0 until items.length()) {
                    val item = items.getJSONObject(index)
                    add(
                        PrayerNotificationEntry(
                            id = item.getInt("id"),
                            prayerKey = item.getString("prayerKey"),
                            prayerLabel = item.optString("prayerLabel", ""),
                            title = item.getString("title"),
                            body = item.getString("body"),
                            fireAtMillis = item.getLong("fireAtMillis"),
                        ),
                    )
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "parseEntries: failed to parse payload", e)
            emptyList()
        }
    }

    private fun getPrefs(context: Context): android.content.SharedPreferences {
        // Device-protected storage is accessible before the user unlocks the device
        // after a reboot, which is required for the BootReceiver to restore alarms.
        val storageContext =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                context.createDeviceProtectedStorageContext()
            } else {
                context
            }

        return storageContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    private fun pendingIntentFlags(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
    }

    // OEM battery optimizers (MIUI, EMUI, ColorOS, One UI "deep sleep", etc.) can kill the
    // app process and silently drop otherwise-exact alarms even when canScheduleExactAlarms()
    // is true. Exempting the app from battery optimization meaningfully reduces missed/delayed
    // prayer alarms. Reading the current state only needs PowerManager — no special permission.
    fun isIgnoringBatteryOptimizations(context: Context): Boolean {
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return powerManager.isIgnoringBatteryOptimizations(context.packageName)
    }

    // Opens the standard, per-app battery-optimization settings list and lets the user
    // exempt the app themselves. We deliberately avoid the direct
    // ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS dialog because it needs the restricted
    // REQUEST_IGNORE_BATTERY_OPTIMIZATIONS permission, which Google Play policy limits and
    // which can get the listing rejected. This action requires no special permission.
    fun openBatteryOptimizationSettings(context: Context): Boolean {
        val intents = listOf(
            Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS),
            // Fallback: the app's own details page, from which users can reach
            // "Battery" on devices that don't expose the list activity.
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = android.net.Uri.parse("package:${context.packageName}")
            },
        )

        for (intent in intents) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            try {
                context.startActivity(intent)
                return true
            } catch (e: Exception) {
                Log.w(TAG, "Battery optimization settings intent failed, trying fallback", e)
            }
        }

        Log.e(TAG, "Unable to open any battery optimization settings screen")
        return false
    }

    private fun prayerLabelFromKey(prayerKey: String): String {
        return when (prayerKey.lowercase(Locale.US)) {
            "fajr" -> "الفجر"
            "dhuhr" -> "الظهر"
            "asr" -> "العصر"
            "maghrib" -> "المغرب"
            "isha" -> "العشاء"
            else -> prayerKey
        }
    }

    private fun formatReminderTime(fireAtMillis: Long): String {
        val formatter = SimpleDateFormat("HH:mm", Locale.forLanguageTag("ar"))
        return formatter.format(Date(fireAtMillis))
    }
}
