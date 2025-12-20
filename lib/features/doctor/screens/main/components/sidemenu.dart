import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tbcare_main/core/app_constants.dart'; 
import 'package:tbcare_main/core/responsive.dart';
import 'package:tbcare_main/features/doctor/screens/diet/diet_exercise_screen.dart';
import 'package:tbcare_main/features/doctor/screens/recommendation/recommendation_screen.dart';
import 'package:tbcare_main/features/doctor/screens/screening/screening_daignosis_screen.dart';
import '../../patients/patients_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/web_landing', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDrawerMode = !Responsive.isDesktop(context);

    // Modern polished gradient or solid primary color
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: primaryColor,
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.2),
               blurRadius: 15,
               offset: const Offset(4, 0),
             ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding,
        ),
        child: Column(
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(defaultPadding, defaultPadding, defaultPadding, largePadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isDrawerMode)
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(16), // Rounded square
                       border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                    ),
                    child: Image.asset(
                      "assets/images/logo light.png",
                      height: 60, 
                      width: 60,
                    ),
                  ),
                ],
              ),
            ),

            // Menu items scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: const [
                    DrawerListTile(
                      title: 'Dashboard',
                      svgSrc: "assets/icons/hospital.svg",
                      press: dummy,
                    ),
                    DrawerListTile(
                      title: 'Patients',
                      svgSrc: "assets/icons/activity.svg",
                      press: navigateToPatients,
                    ),
                    DrawerListTile(
                      title: 'Screening & Diagnosis',
                      svgSrc: "assets/icons/graph-up.svg",
                      press: navigateToScreeningAndDiagnosis,
                    ),
                    DrawerListTile(
                      title: 'Recommendation',
                      svgSrc: "assets/icons/recommendation.svg",
                      press: navigateToRecommendations,
                    ),
                    DrawerListTile(
                      title: 'Diet & Exercise',
                      svgSrc: "assets/icons/stats-report.svg",
                      press: navigateToDietExerciseScreen,
                    ),
                    // DrawerListTile(
                    //   title: 'Overall Statistics',
                    //   svgSrc: "assets/icons/graph-up.svg",
                    //   press: dummy,
                    // ),
                  ],
                ),
              ),
            ),

            // Logout button at bottom - Refined size
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1), // Subtle styling instead of jarring red
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text(
                    "Logout", 
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void navigateToPatients(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const PatientsScreen()),
  );
}

void navigateToScreeningAndDiagnosis(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ScreeningDiagnosisScreen()),
  );
}

void navigateToRecommendations(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => RecommendationScreen()),
  );
}

void navigateToDietExerciseScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const DietExerciseScreen()),
  );
}

void dummy(BuildContext context) {}

class DrawerListTile extends StatefulWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.svgSrc,
    required this.press,
  });

  final String title, svgSrc;
  final void Function(BuildContext) press;

  @override
  State<DrawerListTile> createState() => _DrawerListTileState();
}

class _DrawerListTileState extends State<DrawerListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8), // Add spacing between items
        decoration: BoxDecoration(
          color: _isHovered
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12), // More rounded
        ),
        child: ListTile(
          onTap: () => widget.press(context),
          horizontalTitleGap: 12.0,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              widget.svgSrc,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              height: 18,
              width: 18,
            ),
          ),
          title: Text(
            widget.title,
            maxLines: 1, // Enforce single line
            overflow: TextOverflow.ellipsis, // Ellipsis if too long
            style: TextStyle(
              color: _isHovered ? Colors.white : Colors.white.withOpacity(0.8),
              fontSize: 14, // Slightly smaller to fit "Screening & Diagnosis"
              fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      ),
    );
  }
}