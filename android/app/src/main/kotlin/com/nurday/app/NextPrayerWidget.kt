package com.nurday.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Home-screen widget: the next prayer and its time. The app stores today's
 * and tomorrow's times (already calculated on the phone); the widget picks
 * the next one whenever Android refreshes it, so it stays right without the
 * app being opened. Nothing is fetched.
 */
class NextPrayerWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val now = System.currentTimeMillis()
        var name = ""
        var time = ""
        try {
            val times = JSONArray(widgetData.getString("np_times", "[]"))
            for (i in 0 until times.length()) {
                val o = times.getJSONObject(i)
                val t = o.getLong("t")
                if (t > now) {
                    name = o.getString("n")
                    time = SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date(t))
                    break
                }
            }
        } catch (e: Exception) {
            // Leave the widget blank rather than crash the launcher.
        }
        val title = widgetData.getString("np_title", "Next prayer") ?: "Next prayer"
        val empty = widgetData.getString("np_empty", "Open Nurday to set your city")
            ?: "Open Nurday to set your city"
        val place = widgetData.getString("np_place", "") ?: ""
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.next_prayer_widget).apply {
                setTextViewText(R.id.np_title, title)
                setTextViewText(R.id.np_prayer, if (name.isEmpty()) empty else "$name  $time")
                setTextViewText(R.id.np_place, place)
                setOnClickPendingIntent(
                    R.id.np_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
