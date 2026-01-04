import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: const Icon(Icons.shield_moon_rounded, size: 60, color: Colors.indigo),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "FocusFlow",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Version 1.1.2",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            _buildSectionTitle("Our Mission"),
            const Text(
              "We believe that technology should empower you, not distract you. FocusFlow was built to help you reclaim your time and sleep by creating a healthy boundary with your device during the most critical hours of the day.",
              style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF2D2D3A)),
            ),

            const SizedBox(height: 30),

            _buildSectionTitle("The Team"),
            const Text(
              "Developed by Sanskar & Team with a passion for digital wellbeing. We are constantly working to improve FocusFlow and add more features to help you stay focused.",
              style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF2D2D3A)),
            ),

            const SizedBox(height: 30),

            _buildSectionTitle("Legal"),
             ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text("Privacy Policy"),
              onTap: () {
                // TODO: Open Privacy Policy URL
              },
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            ),
             ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined),
              title: const Text("Terms of Service"),
              onTap: () {
                // TODO: Open Terms URL
              },
               trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            ),

            const SizedBox(height: 30),
            Center(
              child: Text(
                "© 2024 FocusFlow Inc.",
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }
}
