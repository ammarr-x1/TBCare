import 'package:flutter/material.dart';
import 'package:tbcare_main/core/responsive.dart';
import 'package:tbcare_main/features/doctor/screens/dashboard/dashboard_screen.dart';
import 'package:tbcare_main/features/doctor/screens/main/components/sidemenu.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void toggleDrawer() {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      Navigator.of(context).pop();
    } else {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      drawer: isDesktop ? null : const SideMenu(),

      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(
                "TB Care Dashboard",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: toggleDrawer,
              ),
            ),

      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) const Expanded(flex: 1, child: SideMenu()),

            // Main content now has a white/light background
            const Expanded(
              flex: 5,
              child: DoctorDashboardScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
