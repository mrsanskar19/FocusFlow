import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

class AppPickerScreen extends StatefulWidget {
  const AppPickerScreen({super.key});

  @override
  State<AppPickerScreen> createState() => _AppPickerScreenState();
}

class _AppPickerScreenState extends State<AppPickerScreen> {
  List<AppInfo> _apps = [];
  List<AppInfo> _filteredApps = [];
  List<String> _exceptionPackages = []; // Apps allowed for 30 mins
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // 🛡️ HIDDEN SYSTEM APPS (Useless to block/allow)
  final List<String> _hiddenPackages = [
   "com.android.systemui",             // System UI
    "com.android.settings",             // Settings
    "com.google.android.packageinstaller", // Installer
    "com.android.vending",              // Play Store
    "com.google.android.inputmethod.latin", // Gboard
    "com.samsung.android.honeyboard",   // Samsung Keyboard
    "com.cycberx.sleeping",             // FocusFlow (Self)
    "com.android.launcher",             // Generic Launchers
    "com.google.android.apps.nexuslauncher", // Pixel Launcher
    "com.sec.android.app.launcher",     // Samsung Launcher
    "android",                          // Android System
  ];

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    // 1. Get ALL apps (include system apps so we can whitelist Phone/Clock)
    List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
    
    // 2. Load the "Night Mode Exceptions" list
    final prefs = await SharedPreferences.getInstance();
    String savedString = prefs.getString('night_exception_apps') ?? "";
    List<String> savedList = savedString.isEmpty ? [] : savedString.split(',');

    // 3. Filter Logic
    List<AppInfo> cleanList = apps.where((app) {
      String pkg = app.packageName ?? "";
      
      if (app.name == null || app.name!.isEmpty) return false;
      
      // Hide technical system components
      if (_hiddenPackages.contains(pkg)) return false;
      if (pkg.contains("launcher")) return false;    // Hide Launchers
      if (pkg.contains("overlay")) return false;     // Hide System Overlays
      if (pkg.contains("provider")) return false;    // Hide System Providers
      if (pkg.contains("inputmethod")) return false; // Hide Keyboards

      return true;
    }).toList();

    // Sort: Selected apps move to the top
    cleanList.sort((a, b) {
      bool aSelected = savedList.contains(a.packageName);
      bool bSelected = savedList.contains(b.packageName);
      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;
      return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
    });

    if (mounted) {
      setState(() {
        _apps = cleanList;
        _filteredApps = cleanList;
        _exceptionPackages = savedList;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSelection() async {
    final prefs = await SharedPreferences.getInstance();
    // Save to the key that the Kotlin backend reads for the 30-min rule
    await prefs.setString('night_exception_apps', _exceptionPackages.join(','));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Night Exceptions Updated"),
          backgroundColor: Colors.indigo,
        )
      );
      Navigator.pop(context);
    }
  }

  void _toggleApp(String packageName) {
    setState(() {
      if (_exceptionPackages.contains(packageName)) {
        _exceptionPackages.remove(packageName);
      } else {
        _exceptionPackages.add(packageName);
      }
    });
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredApps = _apps.where((app) {
        return app.name!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Night Mode Exceptions",
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        actions: [
          FloatingActionButton.small(
            elevation: 0,
            backgroundColor: Colors.indigoAccent,
            onPressed: _saveSelection,
            child: const Icon(Icons.check, color: Colors.white),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          // 1. INFO CARD
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.nights_stay, color: Colors.indigo),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "30-Minute Allowance",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      Text(
                        "Selected apps will work for 30 mins during Night Mode (12-6 AM). All others are blocked strictly.",
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSearch,
              decoration: InputDecoration(
                hintText: "Search apps...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 3. APP LIST
          Expanded(
            child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredApps.length,
                itemBuilder: (context, index) {
                  final app = _filteredApps[index];
                  final isSelected = _exceptionPackages.contains(app.packageName);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected 
                          ? Border.all(color: Colors.indigoAccent, width: 2) 
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: SwitchListTile(
                      activeColor: Colors.indigoAccent,
                      contentPadding: const EdgeInsets.all(8),
                      value: isSelected,
                      onChanged: (val) => _toggleApp(app.packageName!),
                      title: Text(
                        app.name ?? "Unknown", 
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                      subtitle: Text(
                        app.packageName ?? "", 
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: app.icon != null
                          ? Image.memory(app.icon!, width: 32, height: 32)
                          : const Icon(Icons.android, size: 32, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
          ),
        ],
      ),
    );
  }
}