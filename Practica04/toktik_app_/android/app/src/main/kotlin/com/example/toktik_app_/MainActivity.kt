package com.example.toktik_app_

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "toktik/seasonal_icon"
        private val ICON_ALIASES = listOf(
            "LauncherNormal",
            "LauncherHalloween",
            "LauncherChristmas",
            "LauncherValentines",
        )

        private fun aliasForSeason(season: String): String = when (season) {
            "halloween" -> "LauncherHalloween"
            "christmas" -> "LauncherChristmas"
            "valentinesDay" -> "LauncherValentines"
            else -> "LauncherNormal"
        }
    }

    // Respaldo para reintentar la sincronización del icono si Android no acepta
    // el cambio inmediato mientras la app está visible.
    private var pendingLauncherAlias: String? = null

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        pendingLauncherAlias = aliasForSeason(readSavedSeason())
    }

    override fun onPause() {
        super.onPause()
        // Reintento de respaldo cuando la app pasa al fondo.
        applyPendingLauncherAlias()
    }

    override fun onStop() {
        super.onStop()
        // Respaldo para dispositivos que no aplicaron el cambio en onPause.
        applyPendingLauncherAlias()
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
                val selectedAlias = aliasForSeason(season)
                try {
                    // Cambiar los componentes LAUNCHER ahora hace que el icono
                    // del cajón de aplicaciones corresponda al tema seleccionado.
                    setLauncherAlias(selectedAlias)
                    pendingLauncherAlias = null
                    result.success(true)
                } catch (error: Exception) {
                    // Si algún launcher/dispositivo rechaza el cambio en caliente,
                    // vuelve a intentarlo cuando la app pase al fondo.
                    pendingLauncherAlias = selectedAlias
                    android.util.Log.w("TokTikIcon", "No se pudo aplicar el icono inmediatamente", error)
                    result.error("ICON_CHANGE_FAILED", error.message, null)
                }
            }
    }

    private fun readSavedSeason(): String {
        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val savedMode = prefs.getString("flutter.toktik_season_mode", "normal") ?: "normal"
        if (savedMode != "automatic") return savedMode

        val calendar = java.util.Calendar.getInstance()
        val month = calendar.get(java.util.Calendar.MONTH) + 1
        val day = calendar.get(java.util.Calendar.DAY_OF_MONTH)
        return when {
            (month == 10 && day >= 28) || (month == 11 && day <= 2) -> "halloween"
            month == 12 -> "christmas"
            month == 2 && day <= 14 -> "valentinesDay"
            else -> "normal"
        }
    }

    private fun applyPendingLauncherAlias() {
        val selectedAlias = pendingLauncherAlias ?: return
        pendingLauncherAlias = null

        try {
            if (!isAliasConfigurationCurrent(selectedAlias)) {
                setLauncherAlias(selectedAlias)
            }
        } catch (error: Exception) {
            android.util.Log.w("TokTikIcon", "No se pudo aplicar el icono pendiente", error)
        }
    }

    private fun isAliasConfigurationCurrent(selectedAlias: String): Boolean {
        return ICON_ALIASES.all { alias ->
            val component = ComponentName(packageName, "$packageName.$alias")
            val enabled = packageManager.getActivityInfo(component, 0).enabled
            enabled == (alias == selectedAlias)
        }
    }

    private fun setLauncherAlias(selectedAlias: String) {
        val pm = packageManager
        if (isAliasConfigurationCurrent(selectedAlias)) return

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            // API 33+ cambia los cuatro aliases en una operación para evitar que
            // el launcher vea un estado intermedio con cero o varios iconos.
            val changes = ICON_ALIASES.map { aliasName ->
                PackageManager.ComponentEnabledSetting(
                    ComponentName(packageName, "$packageName.$aliasName"),
                    if (aliasName == selectedAlias) {
                        PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                    } else {
                        PackageManager.COMPONENT_ENABLED_STATE_DISABLED
                    },
                    PackageManager.DONT_KILL_APP,
                )
            }.toMutableList()
            pm.setComponentEnabledSettings(changes)
        } else {
            // En Android 7–12 se habilita primero el destino para no dejar al
            // usuario sin un icono desde el que pueda abrir la aplicación.
            pm.setComponentEnabledSetting(
                ComponentName(packageName, "$packageName.$selectedAlias"),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP,
            )
            ICON_ALIASES.filter { it != selectedAlias }.forEach { aliasName ->
                pm.setComponentEnabledSetting(
                    ComponentName(packageName, "$packageName.$aliasName"),
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP,
                )
            }
        }
    }
}
