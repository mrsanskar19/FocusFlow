package com.cycberx.sleeping

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.widget.Toast
import java.util.Calendar

class AppBlockerService : AccessibilityService() {

    // Store when an app was first opened: Map<PackageName, StartTimeMillis>
    private val appUsageStartTimes = mutableMapOf<String, Long>()
    private val MAX_USAGE_TIME_MS = 30 * 60 * 1000 // 30 Minutes

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val currentPackage = event.packageName?.toString() ?: return
            
            // 1. SAFETY FIRST: Never block these core apps
            if (isSystemApp(currentPackage)) return

            // 2. CHECK: Is the "Block Mode" active?
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val isManualBlock = prefs.getBoolean("flutter.manual_lock", false)
            
            // Logic: Auto-start between 12 AM (0) and 6 AM (6)
            val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
            val isNightTime = hour in 0..6 

            if (isManualBlock || isNightTime) {
                
                // 3. READ USER'S ALLOWED APPS
                // We read the comma-separated string we just saved in Flutter
                val allowedAppsString = prefs.getString("flutter.allowed_apps", "") ?: ""
                val allowedList = allowedAppsString.split(",").map { it.trim() }

                if (allowedList.contains(currentPackage)) {
                    // This is an Allowed App (one of the 5). Check the 30-min timer.
                    checkTimeLimit(currentPackage)
                } else {
                    // Not in the allowed list? BLOCK IT.
                    blockApp("Restricted App")
                }
            } else {
                // If block mode is OFF, reset timers so they are fresh for next time
                appUsageStartTimes.clear()
            }
        }
    }

    private fun checkTimeLimit(packageName: String) {
        val currentTime = System.currentTimeMillis()
        
        // If this is the first time seeing this app today/session, save start time
        if (!appUsageStartTimes.containsKey(packageName)) {
            appUsageStartTimes[packageName] = currentTime
        }

        val startTime = appUsageStartTimes[packageName] ?: currentTime
        val timeUsed = currentTime - startTime

        if (timeUsed > MAX_USAGE_TIME_MS) {
            blockApp("30 min limit reached for this app!")
        }
    }

    private fun blockApp(message: String) {
        performGlobalAction(GLOBAL_ACTION_HOME)
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }

    private fun isSystemApp(packageName: String): Boolean {
        // Dynamic Launcher Detection (Home Screen)
        val launcherPkg = getLauncherPackageName()
        
        val safeApps = listOf(
            "com.android.systemui",              // Status Bar / Notifications
            "com.google.android.inputmethod.latin", // Gboard Keyboard
            "com.android.settings",              // Settings
            "com.google.android.permissioncontroller", // Permissions
            "com.cycberx.sleeping",              // OUR APP (Don't block yourself!)
            launcherPkg                          // The Home Screen
        )
        return safeApps.contains(packageName)
    }

    private fun getLauncherPackageName(): String? {
        val intent = Intent(Intent.ACTION_MAIN)
        intent.addCategory(Intent.CATEGORY_HOME)
        val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        return resolveInfo?.activityInfo?.packageName
    }

    override fun onInterrupt() {
        // Required method, leave empty
    }
}