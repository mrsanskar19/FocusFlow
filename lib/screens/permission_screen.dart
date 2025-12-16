import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dashboard_screen.dart'; 

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver {
  bool _isNotificationGranted = false;
  bool _isAccessibilityGranted = false;
  
  static const platform = MethodChannel('com.cycberx.sleeping/settings');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final notifStatus = await Permission.notification.status;
    bool accessStatus = false;
    try {
      accessStatus = await platform.invokeMethod('isAccessibilityEnabled');
    } on PlatformException catch (e) {
      debugPrint("Failed to check accessibility: '${e.message}'.");
    }

    if (mounted) {
      setState(() {
        _isNotificationGranted = notifStatus.isGranted;
        _isAccessibilityGranted = accessStatus;
      });

      if (_isNotificationGranted && _isAccessibilityGranted) {
        _navigateToDashboard();
      }
    }
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (_) => const DashboardScreen())
    );
  }

  Future<void> _requestNotification() async {
    await Permission.notification.request();
    _checkPermissions();
  }

  Future<void> _requestAccessibility() async {
    const AndroidIntent intent = AndroidIntent(
      action: 'android.settings.ACCESSIBILITY_SETTINGS',
    );
    await intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Soft White Background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER SECTION
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_rounded, size: 48, color: Colors.deepPurpleAccent),
              ),
              const SizedBox(height: 24),
              const Text(
                "Let's get set up",
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.w800, 
                  color: Colors.black87,
                  letterSpacing: -0.5
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "To automatically block distractions, FocusFlow needs the following permissions enabled.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 40),

              // 2. PERMISSION CARDS
              _buildPermissionCard(
                title: "Notifications",
                subtitle: "Get alerts when apps are blocked or night mode starts.",
                icon: Icons.notifications_active_rounded,
                isGranted: _isNotificationGranted,
                onTap: _requestNotification,
                color: Colors.orangeAccent,
              ),

              const SizedBox(height: 16),

              _buildPermissionCard(
                title: "Accessibility",
                subtitle: "Required to detect and close distracting apps immediately.",
                icon: Icons.accessibility_new_rounded,
                isGranted: _isAccessibilityGranted,
                onTap: _requestAccessibility,
                color: Colors.blueAccent,
              ),

              const Spacer(),

              // 3. FOOTER BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isNotificationGranted && _isAccessibilityGranted) 
                      ? _navigateToDashboard 
                      : null, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Continue to App", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "We value your privacy. Data stays on device.",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required bool isGranted, 
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
        border: isGranted 
          ? Border.all(color: Colors.green.withOpacity(0.5), width: 2)
          : Border.all(color: Colors.transparent),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isGranted ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icon Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isGranted ? Colors.green.withOpacity(0.1) : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isGranted ? Icons.check_rounded : icon,
                    color: isGranted ? Colors.green : color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.black87
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.3),
                      ),
                    ],
                  ),
                ),
                // Action Arrow / Check
                if (!isGranted)
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey)
              ],
            ),
          ),
        ),
      ),
    );
  }
}