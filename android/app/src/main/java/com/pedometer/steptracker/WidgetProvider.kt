package com.pedometer.steptracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider

class HomeScreenWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {

                val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                val steps = widgetData.getInt("_Steps", 0)
                val todaysSteps = "Your counter value is: $steps"

                setTextViewText(R.id.Step_counter, todaysSteps)
                val backgroundIntent=HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse("myAppWidget://updatesteps"))

            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
