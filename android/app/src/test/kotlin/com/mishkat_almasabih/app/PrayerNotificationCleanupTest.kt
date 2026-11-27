package com.mishkat_almasabih.app

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class PrayerNotificationCleanupTest {
    private val tag = PrayerNotificationCleanup.NOTIFICATION_TAG

    // 2026-10-13: Fajr = 1 ... Isha = 5
    private val fajrId = 202610131
    private val dhuhrId = 202610132
    private val asrId = 202610133

    @Test
    fun `earlier prayer reminders are removed when the next prayer fires`() {
        assertTrue(PrayerNotificationCleanup.isPreviousReminder(tag, fajrId, currentId = asrId))
        assertTrue(PrayerNotificationCleanup.isPreviousReminder(tag, dhuhrId, currentId = asrId))
    }

    @Test
    fun `reminder for the prayer firing now is kept`() {
        assertFalse(PrayerNotificationCleanup.isPreviousReminder(tag, asrId, currentId = asrId))
    }

    @Test
    fun `notifications without the prayer tag are not previous reminders`() {
        assertFalse(PrayerNotificationCleanup.isPreviousReminder(null, fajrId, currentId = asrId))
        assertFalse(PrayerNotificationCleanup.isPreviousReminder("ranker_group", Int.MAX_VALUE, currentId = asrId))
    }

    @Test
    fun `untagged reminder posted by an older version is legacy`() {
        assertTrue(PrayerNotificationCleanup.isLegacyReminder(null, fajrId))
        assertTrue(PrayerNotificationCleanup.isLegacyReminder(null, 202612315))
    }

    @Test
    fun `tagged reminder is not legacy`() {
        assertFalse(PrayerNotificationCleanup.isLegacyReminder(tag, fajrId))
    }

    @Test
    fun `untagged notification from another feature is not legacy`() {
        // flutter_local_notifications ids: seconds since epoch, or small sequential ids.
        assertFalse(PrayerNotificationCleanup.isLegacyReminder(null, 1_760_000_003))
        assertFalse(PrayerNotificationCleanup.isLegacyReminder(null, 1003))
    }

    @Test
    fun `untagged id with an invalid month or day is not legacy`() {
        assertFalse(PrayerNotificationCleanup.isLegacyReminder(null, 202613011))
        assertFalse(PrayerNotificationCleanup.isLegacyReminder(null, 202610321))
        assertFalse(PrayerNotificationCleanup.isLegacyReminder(null, 202610001))
    }
}
