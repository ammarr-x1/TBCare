import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tbcare_main/core/app_constants.dart';

class Breakpoints {
  static const double tablet = 900;
  static const double desktop = 1200;
}

class WebLandingScreen extends StatefulWidget {
  const WebLandingScreen({super.key});

  @override
  State<WebLandingScreen> createState() => _WebLandingScreenState();
}

class _WebLandingScreenState extends State<WebLandingScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  int _hoveredIndex = -1;

  Future<void> _handleSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppConstants.signinRoute,
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > Breakpoints.desktop;
    final isTablet = screenSize.width > Breakpoints.tablet && !isDesktop;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(isDesktop),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? screenSize.width * 0.1 : defaultPadding,
                vertical: largePadding,
              ),
              child: _buildDashboardGrid(isDesktop, isTablet),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: isDesktop(context) ? 32 : 16,
      title: Row(
        children: [
          Icon(Icons.local_hospital_rounded, color: primaryColor, size: 32),
          const SizedBox(width: 12),
          Text(
            'TB-Care AI',
            style: GoogleFonts.poppins(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
      actions: [
        if (currentUser != null)
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Text(
                    currentUser!.email?[0].toUpperCase() ?? 'U',
                    style: const TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                if (MediaQuery.of(context).size.width > 600)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome',
                        style: TextStyle(
                            color: secondaryColor.withOpacity(0.6),
                            fontSize: 12),
                      ),
                      Text(
                        currentUser!.email ?? 'User',
                        style: const TextStyle(
                            color: secondaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                    ],
                  ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: secondaryColor),
                  onPressed: _handleSignOut,
                  tooltip: 'Sign Out',
                ),
              ],
            ),
          ),
      ],
    );
  }

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > Breakpoints.desktop;

  Widget _buildHeroSection(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      decoration: BoxDecoration(
        color: primaryColor,
        image: DecorationImage(
          image: const AssetImage('assets/images/splash_bg.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              primaryColor.withOpacity(0.9), BlendMode.srcOver),
          onError: (_, __) {},
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Icon(Icons.dashboard_rounded,
                size: 64, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to Your Dashboard',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 48 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Select your role below to access the appropriate tools, patient records, and diagnostic features.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(bool isDesktop, bool isTablet) {
    int crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
    double aspectRatio = isDesktop ? 1.1 : (isTablet ? 1.0 : 1.4);

    return LayoutBuilder(builder: (context, constraints) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: aspectRatio,
        children: [
          _buildCard(
            index: 0,
            title: 'Doctor Dashboard',
            description: 'Patient Management & AI Diagnostics',
            icon: Icons.medical_services_outlined,
            route: AppConstants.onboardingRoute,
            isImplemented: true,
          ),
          _buildCard(
            index: 1,
            title: 'CHW Dashboard',
            description: 'Community Health Worker Tools',
            icon: Icons.health_and_safety_outlined,
            route: AppConstants.onboardingRoute,
            isImplemented: true,
          ),
          _buildCard(
            index: 2,
            title: 'Admin Dashboard',
            description: 'System Management & Analytics',
            icon: Icons.admin_panel_settings_outlined,
            route: AppConstants.adminRoute,
            isImplemented: false,
          ),
        ],
      );
    });
  }

  Widget _buildCard({
    required int index,
    required String title,
    required String description,
    required IconData icon,
    required String route,
    required bool isImplemented,
  }) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0, isHovered ? -8 : 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(largeRadius),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(isHovered ? 0.15 : 0.05),
              blurRadius: isHovered ? 24 : 12,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isHovered ? primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (isImplemented) {
                Navigator.pushNamed(context, route);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Coming Soon!'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(largeRadius),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isHovered
                          ? primaryColor
                          : primaryColor.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 48,
                      color: isHovered ? Colors.white : primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryColor.withOpacity(0.6),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (!isImplemented)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        'Coming Soon',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                  if (isImplemented)
                    AnimatedOpacity(
                      opacity: isHovered ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Text(
                        'Click to Access',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0, top: 16.0),
      child: Column(
        children: [
          Text(
            '© 2024 TB-Care AI. All rights reserved.',
            style: TextStyle(
              color: secondaryColor.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Advanced Screening & Patient Management System',
            style: TextStyle(
              color: secondaryColor.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}