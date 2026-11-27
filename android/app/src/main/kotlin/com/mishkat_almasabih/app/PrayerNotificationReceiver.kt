package com.mishkat_almasabih.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class PrayerNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val notificationId = intent.getIntExtra(
            PrayerNotificationScheduler.EXTRA_NOTIFICATION_ID,
            -1,
        )
        if (notificationId == -1) return

        val prayerKey = intent.getStringExtra(PrayerNotificationScheduler.EXTRA_PRAYER_KEY)
            ?: return
        val prayerLabel = intent.getStringExtra(PrayerNotificationScheduler.EXTRA_PRAYER_LABEL)
            ?: ""
        val title = intent.getStringExtra(PrayerNotificationScheduler.EXTRA_TITLE) ?: return
        val body = intent.getStringExtra(PrayerNotificationScheduler.EXTRA_BODY) ?: return
        val fireAtMillis = intent.getLongExtra(
            PrayerNotificationScheduler.EXTRA_FIRE_AT_MILLIS,
            System.currentTimeMillis(),
        )
        val kind = intent.getStringExtra(PrayerNotificationScheduler.EXTRA_KIND)
            ?: PrayerNotificationScheduler.KIND_ADHAN
        val prayerAtMillis = intent.getLongExtra(
            PrayerNotificationScheduler.EXTRA_PRAYER_AT_MILLIS,
            fireAtMillis,
        )

        PrayerNotificationScheduler.showPrayerNotification(
            context,
            PrayerNotificationEntry(
                id = notificationId,
                prayerKey = prayerKey,
                prayerLabel = prayerLabel,
                title = title,
                body = body,
                fireAtMillis = fireAtMillis,
                kind = kind,
                prayerAtMillis = prayerAtMillis,
            ),
        )
        PrayerNotificationScheduler.onPrayerNotificationFired(context, notificationId)
    }
}
