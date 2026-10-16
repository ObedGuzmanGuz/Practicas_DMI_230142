package com.example.toktik_app_

import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import java.util.Calendar

class SeasonalIconReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        try {
            val preferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val mode = preferences.getString("flutter.toktik_season_mode", "normal") ?: "normal"
            val season = if (mode != "automatic") mode else seasonForDate()
            setLauncherAlias(context, aliasForSeason(season))
        } catch (error: Exception) {
            Log.w("TokTikIcon", "No se pudo sincronizar el icono estacional", error)
        }
    }

    private fun seasonForDate(): String {
        val calendar = Calendar.getInstance()
        val month = calendar.get(Calendar.MONTH) + 1
        val day = calendar.get(Calendar.DAY_OF_MONTH)
        return when {
            (month == 10 && day >= 28) || (month == 11 && day <= 2) -> "halloween"
            month == 12 -> "christmas"
            month == 2 && day <= 14 -> "valentinesDay"
            else -> "normal"
        }
    }

    private fun aliasForSeason(season: String): String = when (season) {
        "halloween" -> "LauncherHalloween"
        "christmas" -> "LauncherChristmas"
        "valentinesDay" -> "LauncherValentines"
        else -> "LauncherNormal"
    }

    private fun setLauncherAlias(context: Context, selectedAlias: String) {
        val manager = context.packageManager
        manager.setComponentEnabledSetting(
            ComponentName(context.packageName, "${context.packageName}.$selectedAlias"),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP,
        )
        listOf("LauncherNormal", "LauncherHalloween", "LauncherChristmas", "LauncherValentines")
            .filter { it != selectedAlias }
            .forEach { alias ->
                manager.setComponentEnabledSetting(
                    ComponentName(context.packageName, "${context.packageName}.$alias"),
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP,
                )
            }
    }
}
