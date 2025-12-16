import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart'; // Import Flags

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = "1.1.2";

  // --- LOGIC: RESET APP ---
  Future<void> _factoryReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Factory Reset"),
        content: const Text(
            "Are you sure? This will delete all your Blocked Apps, Night Exceptions, and Settings. This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Reset Everything"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Wipes all data
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("App has been reset successfully.")));
        Navigator.pop(context); // Go back to dashboard
      }
    }
  }

  void _openNotificationSettings() {
    // Open Android App Notification Settings
    const AndroidIntent intent = AndroidIntent(
      action: 'android.settings.APP_NOTIFICATION_SETTINGS',
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
      arguments: {
        'android.provider.extra.APP_PACKAGE': 'com.cycberx.sleeping',
      },
    );
    intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we are in Dark Mode for styling
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = isDark ? Colors.blueAccent : Colors.indigo;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- SECTION 1: SCHEDULE ---
          _buildSectionHeader("Night Mode Schedule", headerColor),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.timelapse),
                  title: Text("Strict Guard Time"),
                  subtitle: Text("12:00 AM - 06:00 AM (Fixed)"),
                  trailing: Icon(Icons.lock_clock, size: 16),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.hourglass_bottom),
                  title: Text("Allowance Limit"),
                  subtitle: Text("30 Minutes per app / night"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- SECTION 2: PERMISSIONS ---
          _buildSectionHeader("Permissions", headerColor),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.accessibility_new, color: Colors.green),
                  title: const Text("Accessibility Service"),
                  subtitle: const Text("Required to block apps"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => const AndroidIntent(
                    action: 'android.settings.ACCESSIBILITY_SETTINGS',
                  ).launch(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.orange),
                  title: const Text("Notifications"),
                  subtitle: const Text("Manage alerts & status"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: _openNotificationSettings,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- SECTION 3: DANGER ZONE ---
          _buildSectionHeader("Danger Zone", Colors.redAccent),
          Card(
            color: Colors.red.withOpacity(0.1),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.withOpacity(0.3)),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Factory Reset", 
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              subtitle: const Text("Clear all block lists & timers"),
              onTap: _factoryReset,
            ),
          ),
          const SizedBox(height: 20),

          // --- SECTION 4: ABOUT ---
          _buildSectionHeader("About", Colors.grey),
          Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline),
                title: const Text("Version"),
                trailing: Text(_version, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.code),
                title: Text("Developer"),
                trailing: Text("Sanskar & Team"),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Made with ❤️ for Digital Wellbeing",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}