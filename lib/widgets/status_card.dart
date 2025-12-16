import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final bool isReady;

  const StatusCard({super.key, required this.isReady});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Dynamic Gradient: Purple/Pink if ready, Grey if not
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isReady 
              ? [const Color(0xFF654EA3), const Color(0xFFEAAFC8)] 
              : [const Color(0xFF424242), const Color(0xFF303030)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                isReady ? Icons.shield_moon_rounded : Icons.shield_outlined, 
                size: 48, 
                color: Colors.white
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isReady ? "ACTIVE" : "INACTIVE",
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Text(
            isReady ? "Focus Mode is On" : "Focus Mode is Off",
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 22, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isReady 
              ? "Your selected apps are being blocked." 
              : "Select apps to start your digital detox.",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}