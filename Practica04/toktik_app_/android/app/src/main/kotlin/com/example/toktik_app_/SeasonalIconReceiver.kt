package com.example.toktik_app_

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class SeasonalIconReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        try {
            val season = SeasonalIconManager.seasonFromSavedPreference(context)
            SeasonalIconManager.applySeason(context, season)
            Log.i("TokTikIcon", "Sincronización automática del launcher por ${intent?.action}: $season")
        } catch (error: Exception) {
            Log.w("TokTikIcon", "No se pudo sincronizar el icono estacional", error)
        }
    }
}
