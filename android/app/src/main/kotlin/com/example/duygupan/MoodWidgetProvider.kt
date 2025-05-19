package com.example.duygupan

import android.appwidget.AppWidgetProvider
import android.content.Context
import android.appwidget.AppWidgetManager
import android.widget.RemoteViews
import android.content.SharedPreferences
import android.preference.PreferenceManager

class MoodWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val prefs: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
        val showMood = prefs.getBoolean("widgetShowMood", true)
        val showAvgMood = prefs.getBoolean("widgetShowAvgMood", true)
        val showMotivation = prefs.getBoolean("widgetShowMotivation", true)
        val mood = prefs.getInt("mood", -1)
        val note = prefs.getString("mood_note", "")
        val avgMood = prefs.getFloat("avg_mood", -1f)
        val motivation = prefs.getString("motivation", "")
        val badges = prefs.getString("badges", "")
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.mood_widget)
            // Mood ve not gösterimi
            if (showMood && mood >= 0) {
                views.setViewVisibility(R.id.mood_icon, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.mood_note, android.view.View.VISIBLE)
                views.setTextViewText(R.id.mood_note, note)
                // İkonu mood değerine göre değiştirmek için ek kod eklenebilir
            } else {
                views.setViewVisibility(R.id.mood_icon, android.view.View.GONE)
                views.setViewVisibility(R.id.mood_note, android.view.View.GONE)
            }
            // Ortalama mood gösterimi
            if (showAvgMood && avgMood >= 0) {
                views.setViewVisibility(R.id.avg_mood, android.view.View.VISIBLE)
                views.setTextViewText(R.id.avg_mood, "Ortalama Mood: %.1f".format(avgMood))
            } else {
                views.setViewVisibility(R.id.avg_mood, android.view.View.GONE)
            }
            // Motivasyon mesajı gösterimi
            if (showMotivation && !motivation.isNullOrEmpty()) {
                views.setViewVisibility(R.id.motivation, android.view.View.VISIBLE)
                views.setTextViewText(R.id.motivation, motivation)
            } else {
                views.setViewVisibility(R.id.motivation, android.view.View.GONE)
            }
            // Rozetler gösterimi
            if (!badges.isNullOrEmpty()) {
                views.setViewVisibility(R.id.badges, android.view.View.VISIBLE)
                views.setTextViewText(R.id.badges, "Rozetler: $badges")
            } else {
                views.setViewVisibility(R.id.badges, android.view.View.GONE)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
