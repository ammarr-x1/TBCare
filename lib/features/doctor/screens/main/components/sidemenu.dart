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

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        color: primaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding,
        ),
        child: Column(
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                children: [
                  if (isDrawerMode)
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        "assets/images/logo light.png",
                        height: 80,
                        width: 80,
                      ),
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
                    DrawerListTile(
                      title: 'Overall Statistics',
                      svgSrc: "assets/icons/graph-up.svg",
                      press: dummy,
                    ),
                  ],
                ),
              ),
            ),

            // Logout button at bottom
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: errorColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Logout", style: TextStyle(color: Colors.white)),
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
        decoration: BoxDecoration(
          color: _isHovered
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          onTap: () => widget.press(context),
          horizontalTitleGap: 12.0,
          leading: SvgPicture.asset(
            widget.svgSrc,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            height: 20,
            width: 20,
          ),
          title: Text(
            widget.title,
            style: TextStyle(
              color: _isHovered ? Colors.white : Colors.white70,
              fontSize: 16,
              fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        ),
      ),
    );
  }
}