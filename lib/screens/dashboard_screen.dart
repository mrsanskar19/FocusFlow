import 'dart:async';
import 'package:flutter/material.dart';
import 'app_picker_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin { // Changed to TickerProviderStateMixin for multiple controllers
  
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();

    // 1. PULSE ANIMATION (The "Heartbeat" of the app)
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 2. ENTRANCE ANIMATION (Slide up elements)
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _slideController.forward(); // Start slide up

    // 3. TIMER (Update UI every minute)
    _ticker = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _ticker?.cancel();
    super.dispose();
  }

  // --- LOGIC HELPERS ---
  bool _isNightModeNow() {
    final hour = DateTime.now().hour;
    return hour >= 0 && hour < 6; // 12:00 AM to 05:59 AM
  }

  String _getTimeUntilNightMode() {
    if (_isNightModeNow()) return "Strict Mode Active";
    
    final now = DateTime.now();
    DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
    Duration diff = nextMidnight.difference(now);
    
    String hours = diff.inHours.toString().padLeft(2, '0');
    String mins = (diff.inMinutes % 60).toString().padLeft(2, '0');
    return "Starts in ${hours}h ${mins}m";
  }

  @override
  Widget build(BuildContext context) {
    final bool isNight = _isNightModeNow();
    
    // Theme Colors (Pure Light)
    const bgColor = Color(0xFFF8F9FE); 
    const primaryColor = Color(0xFF6C63FF); // Modern Indigo
    const activeColor = Color(0xFFE94560);  // Soft Red for Active
    const textColor = Color(0xFF2D2D3A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Settings Icon Only)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "System Status",
                        style: TextStyle(
                          color: textColor.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isNight ? "NIGHT GUARD" : "STANDING BY",
                        style: TextStyle(
                          color: isNight ? activeColor : textColor,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings_rounded, color: textColor),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),

              // 2. HERO SECTION (Living Breathing Shield)
              Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Ripple 1
                        _buildRipple(isNight ? activeColor : primaryColor, 280 * _scaleAnimation.value, 0.1),
                        // Outer Ripple 2
                        _buildRipple(isNight ? activeColor : primaryColor, 240 * _scaleAnimation.value, 0.2),
                        
                        // Main Circle
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isNight
                                  ? [const Color(0xFFE94560), const Color(0xFFC72C41)]
                                  : [const Color(0xFF6C63FF), const Color(0xFF5A52D5)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isNight ? activeColor : primaryColor).withOpacity(0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isNight ? Icons.shield_rounded : Icons.timelapse_rounded,
                                size: 64,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _getTimeUntilNightMode(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const Spacer(),

              // 3. CONFIGURATION SECTION (Slide Up Animation)
              SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CONFIGURATION",
                      style: TextStyle(
                        color: textColor.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Single Full-Width Card for "Unblocked Apps"
                    _buildFeatureCard(
                      context,
                      title: "Night Exceptions",
                      subtitle: "Choose apps allowed for 30 mins.",
                      icon: Icons.app_blocking_rounded,
                      color: Colors.orangeAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AppPickerScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRipple(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF2D2D3A),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.4),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}