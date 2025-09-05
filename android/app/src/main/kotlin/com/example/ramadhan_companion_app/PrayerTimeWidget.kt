package com.example.ramadhan_companion_app


import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Intent

class PrayerTimeWidget : AppWidgetProvider() {


    override fun onEnabled(context: Context) {
        super.onEnabled(context)

        val appWidgetManager = AppWidgetManager.getInstance(context)
        val thisWidget = ComponentName(context, PrayerTimeWidget::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, PrayerTimeWidget::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Refresh every 60 seconds
        alarmManager.setRepeating(
            AlarmManager.RTC,
            System.currentTimeMillis(),
            60 * 1000,
            pendingIntent
        )
    }


    override fun onDisabled(context: Context) {
        super.onDisabled(context)

        // Cancel updates when widget removed
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, PrayerTimeWidget::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(pendingIntent)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.prayer_time_widget)

            val prefs = HomeWidgetPlugin.getData(context)

            val nextPrayer = prefs.getString("next_prayer", "--")
            val nextPrayerTimestamp = prefs.getLong("next_prayer_timestamp", -1L)

            var countdownText = "--"
            if (nextPrayerTimestamp > 0) {
                val now = System.currentTimeMillis()
                val diffMillis = nextPrayerTimestamp - now
                if (diffMillis > 0) {
                    val hours = diffMillis / (1000 * 60 * 60)
                    val minutes = (diffMillis / (1000 * 60)) % 60

                    countdownText = "$hours h $minutes m"
                }
            }

            views.setTextViewText(R.id.next_prayer, "Next Prayer: $nextPrayer")
            views.setTextViewText(R.id.countdown, "Countdown: $countdownText")
            views.setTextViewText(R.id.fajr_time, prefs.getString("fajr", "--"))
            views.setTextViewText(R.id.dhuhr_time, prefs.getString("dhuhr", "--"))
            views.setTextViewText(R.id.asr_time, prefs.getString("asr", "--"))
            views.setTextViewText(R.id.maghrib_time, prefs.getString("maghrib", "--"))
            views.setTextViewText(R.id.isha_time, prefs.getString("isha", "--"))

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}



