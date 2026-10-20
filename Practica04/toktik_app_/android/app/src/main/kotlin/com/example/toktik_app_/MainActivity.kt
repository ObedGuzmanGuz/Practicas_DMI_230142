package com.example.toktik_app_

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "toktik/seasonal_icon"
        private const val TAG = "TokTikIcon"
    }

    private var pendingLauncherSeason: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Respaldo para corregir un icono que haya quedado desincronizado mientras
        // el proceso estaba cerrado o el sistema cambió la fecha del dispositivo.
        pendingLauncherSeason = SeasonalIconManager.seasonFromSavedPreference(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "setLauncherIcon") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val season = call.argument<String>("season") ?: "normal"
                try {
                    // Aplica cada petición, incluso si ya hubo cambios anteriores. No
                    // depende de un estado en caché de los activity-alias.
                    SeasonalIconManager.applySeason(this, season)
                    pendingLauncherSeason = null
                    result.success(true)
                } catch (error: Exception) {
                    pendingLauncherSeason = season
                    Log.w(TAG, "No se pudo aplicar inmediatamente el icono $season", error)
                    result.error("ICON_CHANGE_FAILED", error.message, null)
                }
            }
    }

    override fun onPause() {
        super.onPause()
        applyPendingLauncherSeason()
    }

    override fun onStop() {
        super.onStop()
        applyPendingLauncherSeason()
    }

    private fun applyPendingLauncherSeason() {
        val season = pendingLauncherSeason ?: return
        try {
            SeasonalIconManager.applySeason(this, season)
            pendingLauncherSeason = null
        } catch (error: Exception) {
            Log.w(TAG, "Sigue pendiente la actualización del icono $season", error)
        }
    }
}
