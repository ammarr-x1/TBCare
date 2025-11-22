import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';

class ChwLayout extends StatefulWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Color appBarColor;
  final Color titleColor;
  final bool centerTitle;

  const ChwLayout({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.appBarColor = primaryColor,
    this.titleColor = Colors.white,
    this.centerTitle = true,
  });

  @override
  State<ChwLayout> createState() => _ChwLayoutState();
}

class _ChwLayoutState extends State<ChwLayout> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppConstants.webLandingRoute,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            color: widget.titleColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: widget.centerTitle,
        backgroundColor: widget.appBarColor,
        elevation: 0,
        actions: widget.actions,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            width: 260,
            child: ChwSidebar(),
          ),
          const VerticalDivider(
            width: 1,
            color: Colors.grey,
            thickness: 0.6,
          ),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class ChwSidebar extends StatelessWidget {
  final VoidCallback? onLogout;

  const ChwSidebar({super.key, this.onLogout});

  Widget _item(
    BuildContext context,
    IconData icon,
    String label, {
    VoidCallback? onTap,
    bool selected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? primaryColor.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: selected
            ? Border.all(color: primaryColor.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              selected ? primaryColor : secondaryColor.withOpacity(0.7),
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? primaryColor : secondaryColor,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        selected: selected,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(
                    color: primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo light.png',
                      height: 50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Community Health Worker",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _item(
                    context,
                    Icons.dashboard,
                    'Dashboard',
                    selected: true,
                    onTap: () {
                      Navigator.pushNamed(context, AppConstants.chwDashboardRoute);
                    },
                  ),
                  _item(
                    context,
                    Icons.groups_2,
                    'Patients',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppConstants.managePatientsRoute,
                      );
                    },
                  ),
                  _item(
                    context,
                    Icons.medical_services_outlined,
                    'Screening & Diagnosis',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppConstants.chwScreeningRoute,
                      );
                    },
                  ),
                  _item(
                    context,
                    Icons.assignment_turned_in_outlined,
                    'Follow-ups',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppConstants.chwFollowupsRoute,
                      );
                    },
                  ),
                  _item(
                    context,
                    Icons.send_outlined,
                    'Referrals',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppConstants.chwReferralsRoute,
                      );
                    },
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade200, height: 1),
            Container(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color: errorColor.withOpacity(0.8),
                  size: 22,
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: errorColor.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: onLogout ??
                    () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppConstants.webLandingRoute,
                        (route) => false,
                      );
                    },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

