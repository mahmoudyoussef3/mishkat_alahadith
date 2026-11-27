package com.mishkat_almasabih.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.util.Calendar
import java.util.TimeZone

/**
 * "آية اليوم" on the home screen.
 *
 * The app writes the coming days' ayahs ahead of time, one entry per day, so
 * the widget moves on to the next one each midnight by itself, however long
 * the app stays closed.
 */
class DailyAyahWidgetProvider : AppWidgetProvider() {
    companion object {
        private const val TAG = "DailyAyahWidget"

        /** Written by `DailyAyahWidgetDataSource` in Dart. */
        private const val ENTRIES_KEY = "daily_ayah_entries"

        private const val ACTION_MIDNIGHT_REFRESH =
            "com.mishkat_almasabih.app.action.DAILY_AYAH_WIDGET_REFRESH"
        private const val MIDNIGHT_REFRESH_REQUEST_CODE = 21
        private const val MIDNIGHT_REFRESH_WINDOW_MILLIS = 15 * 60 * 1000L

        /** Gives the widget's tap its own PendingIntent, apart from the other widgets'. */
        private const val ACTION_OPEN = "com.mishkat_almasabih.app.action.OPEN_DAILY_AYAH"
        const val OPEN_SCREEN = "daily_ayah"
        const val EXTRA_PAYLOAD = "daily_ayah_payload"

        /** Ar-Ra'd 13:28, the ayah the fallback strings show. */
        private const val FALLBACK_PAYLOAD = "daily_ayah:1735:252:13"

        private const val MILLIS_PER_DAY = 24 * 60 * 60 * 1000L
    }

    private data class Entry(
        val text: String,
        val reference: String,
        val page: String,
        val payload: String,
    )

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        updateWidgets(context, appWidgetManager, appWidgetIds)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        // A changed clock or time zone can move today to another day, and
        // leaves the pending midnight alarm at the old midnight.
        if (intent.action == ACTION_MIDNIGHT_REFRESH ||
            intent.action == Intent.ACTION_TIME_CHANGED ||
            intent.action == Intent.ACTION_TIMEZONE_CHANGED
        ) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, DailyAyahWidgetProvider::class.java),
            )
            updateWidgets(context, appWidgetManager, appWidgetIds)
        }
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        alarmManager(context).cancel(midnightRefreshIntent(context))
    }

    private fun updateWidgets(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        if (appWidgetIds.isEmpty()) return

        val entry = todaysEntry(context)
        for (appWidgetId in appWidgetIds) {
            try {
                appWidgetManager.updateAppWidget(
                    appWidgetId,
                    buildViews(context, appWidgetId, entry),
                )
            } catch (e: Exception) {
                Log.e(TAG, "Failed to update daily ayah widget $appWidgetId", e)
            }
        }
        scheduleMidnightRefresh(context)
    }

    private fun buildViews(context: Context, appWidgetId: Int, entry: Entry?): RemoteViews =
        RemoteViews(context.packageName, R.layout.daily_ayah_widget).apply {
            // Without an entry the layout keeps its fallback ayah.
            if (entry != null) {
                setTextViewText(R.id.daily_ayah_text, entry.text)
                setTextViewText(R.id.daily_ayah_reference, entry.reference)
                setTextViewText(R.id.daily_ayah_page, entry.page)
            }

            val intent = Intent(context, MainActivity::class.java).apply {
                action = ACTION_OPEN
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("open_screen", OPEN_SCREEN)
                putExtra("from_widget", true)
                putExtra(EXTRA_PAYLOAD, entry?.payload ?: FALLBACK_PAYLOAD)
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            setOnClickPendingIntent(R.id.daily_ayah_widget_root, pendingIntent)
        }

    /**
     * Today's entry. Past the last day written — the app was not opened and
     * the background refresh did not run — the days written are shown again
     * in turn, so the widget still changes daily.
     */
    private fun todaysEntry(context: Context): Entry? {
        val raw = HomeWidgetPlugin.getData(context).getString(ENTRIES_KEY, null) ?: return null
        return try {
            val entries = JSONArray(raw)
            if (entries.length() == 0) return null

            val today = epochDay(Calendar.getInstance())
            val match: JSONObject = (0 until entries.length())
                .map { entries.getJSONObject(it) }
                .firstOrNull { it.getLong("day") == today }
                ?: run {
                    val daysAfterFirst = today - entries.getJSONObject(0).getLong("day")
                    val index =
                        if (daysAfterFirst < 0) 0 else (daysAfterFirst % entries.length()).toInt()
                    entries.getJSONObject(index)
                }

            Entry(
                text = match.getString("text"),
                reference = match.getString("reference"),
                page = match.getString("page"),
                payload = match.getString("payload"),
            )
        } catch (e: JSONException) {
            Log.e(TAG, "Unreadable daily ayah widget data", e)
            null
        }
    }

    /** Days from 1 January 1970 to [calendar]'s date, as Dart counts them. */
    private fun epochDay(calendar: Calendar): Long {
        val utcMidnight = Calendar.getInstance(TimeZone.getTimeZone("UTC")).apply {
            clear()
            set(
                calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH),
                calendar.get(Calendar.DAY_OF_MONTH),
            )
        }
        return utcMidnight.timeInMillis / MILLIS_PER_DAY
    }

    /**
     * Wakes the widget just after midnight for the next day's ayah. RTC rather
     * than RTC_WAKEUP: nobody sees the widget while the screen is off, so it
     * can wait for the device to wake. A set window, because a plain inexact
     * alarm a day away may be put off by most of that day.
     */
    private fun scheduleMidnightRefresh(context: Context) {
        val nextMidnight = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 1)
            set(Calendar.MILLISECOND, 0)
        }
        alarmManager(context).setWindow(
            AlarmManager.RTC,
            nextMidnight.timeInMillis,
            MIDNIGHT_REFRESH_WINDOW_MILLIS,
            midnightRefreshIntent(context),
        )
    }

    private fun midnightRefreshIntent(context: Context): PendingIntent =
        PendingIntent.getBroadcast(
            context,
            MIDNIGHT_REFRESH_REQUEST_CODE,
            Intent(context, DailyAyahWidgetProvider::class.java).apply {
                action = ACTION_MIDNIGHT_REFRESH
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

    private fun alarmManager(context: Context): AlarmManager =
        context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
}
