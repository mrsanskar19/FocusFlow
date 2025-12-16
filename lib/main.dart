import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart'; // Point to new screen

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Make top bar see-through
    statusBarIconBrightness: Brightness.dark, // Make Time/Battery Black
    systemNavigationBarColor: Color(0xFFF8F9FE), // Match bottom bar to background
    systemNavigationBarIconBrightness: Brightness.dark, // Bottom icons black
  ));
  runApp(const FocusFlowApp());
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
     theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FE), // Your Light Grey BG
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        
        // Fix AppBar globally to remove blue shadow
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark, // Double check for dark icons
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87, 
            fontSize: 20, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      home: const SplashScreen(), 
    );
  }
}