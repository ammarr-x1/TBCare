import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tbcare_main/core/app_constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // No automatic navigation - wait for user interaction
  }

  // Method to continue to onboarding
  void _navigateToOnboarding() {
    Navigator.pushReplacementNamed(context, AppConstants.onboardingRoute);
  }

  // Keep the authentication check logic but don't call it automatically
  Future<void> _checkUserStatusManually() async {
    final user = _auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, AppConstants.onboardingRoute);
      return;
    }

    await user.reload();
    if (!user.emailVerified) {
      Navigator.pushReplacementNamed(context, AppConstants.signinRoute);
      return;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        Navigator.pushReplacementNamed(context, AppConstants.signinRoute);
        return;
      }

      final role = userDoc['role'];
      if (role == 'Patient') {
        Navigator.pushReplacementNamed(context, AppConstants.patientRoute);
      } else if (role == 'CHW') {
        Navigator.pushReplacementNamed(context, AppConstants.chwRoute);
      } else if (role == 'Doctor') {
        Navigator.pushReplacementNamed(context, AppConstants.doctorRoute);
      } else {
        Navigator.pushReplacementNamed(context, AppConstants.signinRoute);
      }
    } catch (e) {
      Navigator.pushReplacementNamed(context, AppConstants.signinRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF212332), // dark background
      body: Container(
        // Add a subtle gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF212332),
              Color(0xFF2A2D3E),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo placeholder or your actual logo
              Container(
                height: screenHeight * 0.2,
                width: screenWidth * 0.4,
                decoration: BoxDecoration(
                  color: const Color(0xFF2697FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  size: 100,
                  color: Color(0xFF2697FF),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'TB-CareAI',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2697FF), // primaryColor
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'AI-powered TB screening & guidance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),

              // Continue Button instead of automatic loading
              ElevatedButton(
                onPressed: _navigateToOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2697FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}