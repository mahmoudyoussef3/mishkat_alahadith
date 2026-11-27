package com.mishkat_almasabih.app

// Only the latest prayer reminder should stay in the shade: when a prayer fires,
// every earlier prayer reminder still showing is stale and gets cancelled.
// Kept free of Android APIs so it can be covered by plain JVM unit tests.
internal object PrayerNotificationCleanup {
    // Shared by every prayer reminder so earlier ones can be found and removed.
    // Each reminder still uses its own id, so it alerts as a fresh notification.
    const val NOTIFICATION_TAG = "prayer_time"

    fun isPreviousReminder(tag: String?, id: Int, currentId: Int): Boolean {
        return tag == NOTIFICATION_TAG && id != currentId
    }

    // Older versions posted prayer reminders untagged, with yyyyMMdd * 10 +
    // prayer index (1..5) as the id; the date bounds keep other untagged
    // notifications from matching. Only needed once after upgrading.
    fun isLegacyReminder(tag: String?, id: Int): Boolean {
        if (tag != null) return false

        val prayerIndex = id % 10
        val dateKey = id / 10
        val year = dateKey / 10000
        val month = dateKey / 100 % 100
        val day = dateKey % 100
        return prayerIndex in 1..5 && year in 2000..2100 && month in 1..12 && day in 1..31
    }
}
