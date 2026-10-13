package com.mishkat_almasabih.app


import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.util.Log

class HadithWidgetProvider : AppWidgetProvider() {
    private val TAG = "HadithWidgetProvider"

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "onUpdate: Widget update initiated.")
        for (appWidgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.hadith_widget).apply {
                    val widgetData = HomeWidgetPlugin.getData(context)

                    val hadithText = widgetData.getString("hadith_text", "إنما الأعمال بالنيات")
                    Log.d(TAG, "onUpdate: Retrieved hadithText: $hadithText")

                    setTextViewText(R.id.hadith_text, hadithText)
                    setTextViewText(
                        R.id.hadith_widget_attribution,
                        widgetData.getString("hadith_attribution", null).orEmpty(),
                    )

                    val grade = widgetData.getString("hadith_grade", null)
                    if (grade.isNullOrBlank()) {
                        setViewVisibility(R.id.hadith_grade, View.GONE)
                    } else {
                        setTextViewText(R.id.hadith_grade, grade)
                        setViewVisibility(R.id.hadith_grade, View.VISIBLE)
                    }

                    // Create an Intent to launch the app
                    val intent = Intent(context, MainActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                        // Add extra to indicate we want to open the Hadith of the Day screen
                        putExtra("open_screen", "hadith_of_the_day")
                        putExtra("from_widget", true)
                    }

                    val pendingIntent = PendingIntent.getActivity(
                        context,
                        appWidgetId,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )

                    // Set click listener on the entire widget
                    setOnClickPendingIntent(R.id.hadith_widget_root, pendingIntent)
                    
                    Log.d(TAG, "onUpdate: Click listener set for widget $appWidgetId")
                }
                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d(TAG, "onUpdate: Widget $appWidgetId updated successfully.")
            } catch (e: Exception) {
                Log.e(TAG, "onUpdate: Error updating widget $appWidgetId: ${e.message}", e)
            }
        }
    }
}