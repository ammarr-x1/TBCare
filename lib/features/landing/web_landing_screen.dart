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

class _WebLandingScreenState extends State<WebLandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final User? currentUser = FirebaseAuth.instance.currentUser;
  int _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

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
          backgroundColor: errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > Breakpoints.tablet;
    final isDesktop = screenSize.width > Breakpoints.desktop;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.all(
                    isDesktop ? extraLargePadding : defaultPadding,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(isDesktop),
                      SizedBox(height: isDesktop ? 64 : 32),
                      _buildDashboardGrid(screenSize, isTablet, isDesktop),
                      SizedBox(height: isDesktop ? 64 : 32),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      backgroundColor: Colors.white,
      pinned: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor.withOpacity(0.2), primaryColor.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.local_hospital, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Text(
            'TB-Care AI',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: primaryColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        if (currentUser != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primaryColor.withOpacity(0.8), accentColor],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Text(
                      currentUser!.email?[0].toUpperCase() ?? 'U',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome!',
                      style: TextStyle(
                        color: secondaryColor.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      currentUser!.email ?? "User",
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _handleSignOut,
                  icon: Icon(Icons.logout_rounded, color: errorColor),
                  tooltip: 'Sign Out',
                  style: IconButton.styleFrom(
                    backgroundColor: errorColor.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Column(
      children: [
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primaryColor.withOpacity(0.2), accentColor.withOpacity(0.1)],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.dashboard_rounded,
              size: isDesktop ? 80 : 60,
              color: primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Dashboard Selection',
          style: GoogleFonts.poppins(
            fontSize: isDesktop ? 42 : 32,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),
          child: Text(
            'Choose Your Role to access appropriate Dashboard',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: primaryColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardGrid(Size screenSize, bool isTablet, bool isDesktop) {
    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
    final childAspectRatio = isDesktop ? 1.2 : (isTablet ? 1.1 : 1.3);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : double.infinity),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: childAspectRatio,
        children: [
          _buildDashboardCard(
            index: 0,
            title: 'Doctor Dashboard',
            subtitle: 'Patient Management & Diagnostics',
            icon: Icons.medical_services_rounded,
            color: accentColor,
            route: AppConstants.onboardingRoute,
            description: 'Review AI Screenings, AI Predictions, and provide medical assessments',
            isImplemented: true,
          ),
          _buildDashboardCard(
            index: 1,
            title: 'CHW Dashboard',
            subtitle: 'Community Health Worker Tools',
            icon: Icons.health_and_safety_rounded,
            color: successColor,
            route: AppConstants.onboardingRoute,
            description: 'Community screening tools and patient follow-up management',
            isImplemented: true,
          ),
          _buildDashboardCard(
            index: 2,
            title: 'Admin Dashboard',
            subtitle: 'System Management & Analytics',
            icon: Icons.admin_panel_settings_rounded,
            color: Color(0xFF9B59B6),
            route: AppConstants.adminRoute,
            description: 'User management, system analytics, and platform monitoring',
            isImplemented: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
    required String description,
    required bool isImplemented,
  }) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
        child: Card(
          color: Colors.white,
          elevation: isHovered ? 16 : 4,
          shadowColor: color.withOpacity(isHovered ? 0.4 : 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isHovered ? color.withOpacity(0.5) : color.withOpacity(0.2),
              width: isHovered ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              if (isImplemented) {
                Navigator.pushNamed(context, route);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title is coming Soon!'),
                    backgroundColor: warningColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    color.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(isHovered ? 0.3 : 0.2),
                              color.withOpacity(isHovered ? 0.2 : 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isHovered
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(icon, color: color, size: 36),
                      ),
                      const Spacer(),
                      if (!isImplemented)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: warningColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: warningColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            'Coming Soon',
                            style: TextStyle(
                              color: warningColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isImplemented)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: successColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: successColor.withOpacity(0.3)),
                          ),
                          child: Icon(Icons.check_rounded, color: successColor, size: 18),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryColor.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: ElevatedButton(
                            onPressed: isImplemented
                                ? () => Navigator.pushNamed(context, route)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isImplemented ? color : secondaryColor.withOpacity(0.3),
                              foregroundColor: Colors.white,
                              elevation: isHovered && isImplemented ? 8 : 0,
                              shadowColor: color.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isImplemented ? 'Open Dashboard' : 'Coming Soon',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                if (isImplemented) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  primaryColor.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${AppConstants.appName} ${AppConstants.version} | Healthcare Management System',
                style: TextStyle(
                  color: secondaryColor.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'AI powered tuberculosis screening and patient care platform',
            style: TextStyle(
              color: secondaryColor.withOpacity(0.6),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}