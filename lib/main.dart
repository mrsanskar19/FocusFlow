import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:installed_apps/installed_apps.dart'; 
import 'package:installed_apps/app_info.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PermissionCheckScreen(), // Starts here
  ));
}

// --- SCREEN 1: PERMISSION CHECKER ---
class PermissionCheckScreen extends StatelessWidget {
  const PermissionCheckScreen({super.key});

  void _openSettings(String action) {
    AndroidIntent(
      action: action,
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    ).launch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text("Setup CyberX", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("To function, we need these permissions enabled in Settings.", 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            
            _buildPermButton("1. Grant Usage Access", Icons.data_usage, 'android.settings.USAGE_ACCESS_SETTINGS'),
            const SizedBox(height: 15),
            _buildPermButton("2. Grant Accessibility", Icons.accessibility, 'android.settings.ACCESSIBILITY_SETTINGS'),
            
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              child: const Text("I Have Granted Them -> Go to App"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPermButton(String text, IconData icon, String action) {
    return ListTile(
      tileColor: Colors.grey[900],
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: () => _openSettings(action),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

// --- SCREEN 2: DASHBOARD ---
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isManualLockActive = false;
  List<String> _allowedApps = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isManualLockActive = prefs.getBool('manual_lock') ?? false;
      _allowedApps = prefs.getStringList('allowed_apps') ?? [];
    });
  }

  Future<void> _toggleLock(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('manual_lock', value);
    setState(() => _isManualLockActive = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("CyberX Dashboard"),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isManualLockActive ? Colors.deepPurple : Colors.grey[850],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(_isManualLockActive ? Icons.lock : Icons.lock_open, size: 40, color: Colors.white),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_isManualLockActive ? "SYSTEM ARMED" : "SYSTEM STANDBY", 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(_isManualLockActive ? "Only allowed apps work." : "All apps accessible.",
                          style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  Switch(value: _isManualLockActive, onChanged: _toggleLock, activeThumbColor: Colors.white),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // App Selection Section
            const Text("Configuration", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 10),
            
            ListTile(
              tileColor: Colors.grey[900],
              title: const Text("Allowed Applications", style: TextStyle(color: Colors.white)),
              subtitle: Text("${_allowedApps.length} / 5 Selected (30 mins each)", style: const TextStyle(color: Colors.greenAccent)),
              trailing: const Icon(Icons.edit, color: Colors.white),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const AppPickerScreen()));
                _loadData(); // Reload list after returning
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- SCREEN 3: APP PICKER ---
class AppPickerScreen extends StatefulWidget {
  const AppPickerScreen({super.key});

  @override
  State<AppPickerScreen> createState() => _AppPickerScreenState();
}

class _AppPickerScreenState extends State<AppPickerScreen> {
  // 2. CHANGE TYPE: Use 'AppInfo' instead of 'Application'
  List<AppInfo> _apps = [];
  List<String> _selectedPackageNames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApps();
  }

  Future<void> _fetchApps() async {
    // 3. CHANGE METHOD: Use InstalledApps.getInstalledApps()
    // default behavior is excludeSystemApps=true, which is what we want
    List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
    
    // Load saved selection
    final prefs = await SharedPreferences.getInstance();
    // We handle the split carefully to avoid errors if file is empty
    String savedString = prefs.getString('allowed_apps') ?? "";
    final saved = savedString.isEmpty ? <String>[] : savedString.split(',');

    setState(() {
      _apps = apps;
      _selectedPackageNames = saved;
      _isLoading = false;
    });
  }

  Future<void> _saveSelection() async {
    final prefs = await SharedPreferences.getInstance();
    // Join with commas for the Kotlin side
    await prefs.setString('allowed_apps', _selectedPackageNames.join(','));
    if (mounted) Navigator.pop(context);
  }

  void _onAppToggle(String packageName, bool selected) {
    setState(() {
      if (selected) {
        if (_selectedPackageNames.length < 5) {
          _selectedPackageNames.add(packageName);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Maximum 5 apps allowed!")));
        }
      } else {
        _selectedPackageNames.remove(packageName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Select 5 Apps"), 
        backgroundColor: Colors.grey[900], 
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _saveSelection, icon: const Icon(Icons.save, color: Colors.greenAccent))
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView.builder(
            itemCount: _apps.length,
            itemBuilder: (context, index) {
              final app = _apps[index];
              final isSelected = _selectedPackageNames.contains(app.packageName);
              
              return CheckboxListTile(
                value: isSelected,
                onChanged: (val) => _onAppToggle(app.packageName, val!),
                title: Text(app.name ?? "Unknown", style: const TextStyle(color: Colors.white)),
                // 4. ICON HANDLING: installed_apps returns specific icon data
                secondary: app.icon != null 
                    ? Image.memory(app.icon!, width: 40) 
                    : const Icon(Icons.android, color: Colors.white),
                activeColor: Colors.deepPurple,
                checkColor: Colors.white,
                tileColor: isSelected ? Colors.deepPurple.withOpacity(0.2) : null,
              );
            },
          ),
    );
  }
}