package com.cycberx.sleeping

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.content.SharedPreferences
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import android.widget.Toast
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.util.Calendar

class AppBlockerService : AccessibilityService() {

    private lateinit var prefs: SharedPreferences
    private val CHANNEL_ID = "FocusFlow_Status"
    private val NOTIFICATION_ID_STATUS = 1001
    
    // 🛡️ CRITICAL SAFETY LIST (Never Block These)
    private val systemEssentialApps = listOf(
        "com.android.systemui",             // Notification Shade / Nav Bar
        "com.android.settings",             // Settings (To prevent lockout)
        "com.google.android.packageinstaller", // Installer
        "com.android.vending",              // Play Store
        "com.google.android.inputmethod.latin", // Gboard
        "com.samsung.android.honeyboard",   // Samsung Keyboard
        "com.cycberx.sleeping"              // FocusFlow (Your App)
    )
    override fun onServiceConnected() {
        super.onServiceConnected()
        prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        createNotificationChannel()
        Log.d("FocusFlow", "✅ Service Connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null || event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            return
        }

        prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val packageName = event.packageName?.toString() ?: return

        // 1. SAFETY CHECKS
        if (systemEssentialApps.contains(packageName)) return
        if (packageName.contains("inputmethod")) return
        if (isLauncher(packageName)) return

        // 2. CHECK TIME & STATUS
        val currentHour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY) // 0 - 23
        val isNightMode = currentHour in 0..5 // 12:00 AM to 05:59 AM

        // --- NEW: NOTIFICATION LOGIC ---
        // We check if the state changed since the last time we checked
        val lastStateNight = prefs.getBoolean("native_last_state_night", false)

        if (isNightMode && !lastStateNight) {
            // Day -> Night Transition
            sendNotification("Strict Mode Active 🌙", "Sleep tight! Apps are blocked until 6 AM.")
            prefs.edit().putBoolean("native_last_state_night", true).apply()
        } 
        else if (!isNightMode && lastStateNight) {
            // Night -> Day Transition
            sendNotification("FocusFlow Relaxed ☀️", "Good morning! Apps are unblocked.")
            prefs.edit().putBoolean("native_last_state_night", false).apply()
        }

        if (!isNightMode) return // Stop if it's day time

        // 3. NIGHT MODE HANDLING
        handleNightMode(packageName)
    }

    private fun handleNightMode(packageName: String) {
        val exceptionString = prefs.getString("flutter.night_exception_apps", "") ?: ""
        val exceptionApps = exceptionString.split(",").filter { it.isNotEmpty() }

        if (exceptionApps.contains(packageName)) {
            checkTimeLimit(packageName)
        } else {
            Log.d("FocusFlow", "Block: $packageName")
            blockApp(packageName, "⛔ Blocked: Strict Night Mode")
        }
    }

    private fun checkTimeLimit(packageName: String) {
        val key = "flutter.timer_$packageName"
        val expiryTime = prefs.getLong(key, -1L)
        val currentTime = System.currentTimeMillis()

        if (expiryTime == -1L) {
            // Start 30 min timer
            val newExpiry = currentTime + 1800000 // 30 mins
            prefs.edit().putLong(key, newExpiry).apply()
            
            // Notify user
            val appName = getAppNameFromPackage(packageName)
            sendNotification("Timer Started ⏳", "You have 30 mins to use $appName.")
        } else {
            if (currentTime > expiryTime) {
                blockApp(packageName, "⏳ Time's up for this app!")
            } else {
                // Optional: Notify on 5 mins left? (Can be added later)
            }
        }
    }

    private fun blockApp(pkg: String, reason: String) {
        // 1. Action
        performGlobalAction(GLOBAL_ACTION_HOME)
        performGlobalAction(GLOBAL_ACTION_HOME)

        // 2. Feedback (Toast + Notification)
        Toast.makeText(applicationContext, reason, Toast.LENGTH_SHORT).show()
        
        // We don't spam notifications, only show if it's a new block event
        val lastBlockTime = prefs.getLong("last_block_notif_time", 0L)
        if (System.currentTimeMillis() - lastBlockTime > 5000) { // Max 1 notif per 5 secs
            sendNotification("FocusFlow Guard", reason)
            prefs.edit().putLong("last_block_notif_time", System.currentTimeMillis()).apply()
        }
    }

    // --- NOTIFICATION HELPERS ---

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "FocusFlow Status"
            val descriptionText = "Notifications for Active/Off status and blocks"
            val importance = NotificationManager.IMPORTANCE_DEFAULT // Sound + Vibrate
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun sendNotification(title: String, content: String) {
        // Open the app when notification is clicked
        val intent = packageManager.getLaunchIntentForPackage("com.cycberx.sleeping")
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_lock) // Uses generic Android lock icon
            .setContentTitle(title)
            .setContentText(content)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)

        try {
            val notificationManager = NotificationManagerCompat.from(this)
            // Permission check for Android 13+ is handled by system logic in services mostly,
            // or we assume user granted it in UI.
            notificationManager.notify(NOTIFICATION_ID_STATUS, builder.build())
        } catch (e: SecurityException) {
            Log.e("FocusFlow", "Notification Permission missing")
        }
    }

    private fun isLauncher(packageName: String): Boolean {
        val intent = Intent(Intent.ACTION_MAIN)
        intent.addCategory(Intent.CATEGORY_HOME)
        val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        return resolveInfo?.activityInfo?.packageName == packageName
    }

    private fun getAppNameFromPackage(packageName: String): String {
        return try {
            val appInfo = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(appInfo).toString()
        } catch (e: Exception) {
            "App"
        }
    }

    override fun onInterrupt() {}
}