package com.example.toktik_app_

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import java.util.Calendar

/** Centraliza los alias del launcher y la decisión de temporada por fecha. */
internal object SeasonalIconManager {
    private const val TAG = "TokTikIcon"
    private val aliases = listOf(
        "LauncherNormal",
        "LauncherHalloween",
        "LauncherChristmas",
        "LauncherValentines",
    )

    fun seasonFromSavedPreference(context: Context): String {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val savedMode = prefs.getString("flutter.toktik_season_mode", "normal") ?: "normal"
        return if (savedMode == "automatic") seasonForDate() else normalizeSeason(savedMode)
    }

    fun seasonForDate(): String {
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

    fun applySeason(context: Context, season: String) {
        val selected = aliasForSeason(season)
        val manager = context.packageManager
        val settings = aliases.map { alias ->
            PackageManager.ComponentEnabledSetting(
                ComponentName(context.packageName, "${context.packageName}.$alias"),
                if (alias == selected) {
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                } else {
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED
                },
                PackageManager.DONT_KILL_APP,
            )
        }

        // Android 13+ admite actualizar el grupo de aliases atómicamente. Si un
        // fabricante falla en esa API, se aplica el mismo estado de forma secuencial.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            try {
                manager.setComponentEnabledSettings(settings)
                Log.i(TAG, "Icono del launcher actualizado a $selected")
                return
            } catch (error: Exception) {
                Log.w(TAG, "No se pudo aplicar el cambio atómico; usando respaldo", error)
            }
        }

        manager.setComponentEnabledSetting(
            ComponentName(context.packageName, "${context.packageName}.$selected"),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP,
        )
        aliases.filter { it != selected }.forEach { alias ->
            manager.setComponentEnabledSetting(
                ComponentName(context.packageName, "${context.packageName}.$alias"),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP,
            )
        }
        Log.i(TAG, "Icono del launcher actualizado a $selected")
    }

    fun aliasForSeason(season: String): String = when (normalizeSeason(season)) {
        "halloween" -> "LauncherHalloween"
        "christmas" -> "LauncherChristmas"
        "valentinesDay" -> "LauncherValentines"
        else -> "LauncherNormal"
    }

    private fun normalizeSeason(value: String): String = when (value) {
        "halloween", "christmas", "valentinesDay", "normal" -> value
        else -> "normal"
    }
}
