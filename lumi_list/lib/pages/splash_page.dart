import 'dart:async';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Remain open for 2 seconds before redirecting to the login page.
    Timer(const Duration(seconds: 2), () {
      // sink to LoginPage
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The Scaffold here does not require an AppBar and displays in full screen.
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // set the background gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Color(0xFF1A1A1A)], 
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. App Logo
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration( 
                color: Colors.black, 
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/icon/icon.png', // App icon path
                width: 90, 
                height: 90,
                fit: BoxFit.contain,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 2. App Name
            const Text(
              "LumiList",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 3, 
              ),
            ),
            
            const SizedBox(height: 10),
            
            // 3. Slogan part
            Text(
              "Your Movie Collection",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 80),

            // 4. Loading Indicator
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}