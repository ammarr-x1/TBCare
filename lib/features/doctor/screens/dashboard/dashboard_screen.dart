import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'package:tbcare_main/core/responsive.dart';
import 'package:tbcare_main/features/doctor/screens/dashboard/components/header.dart';
import 'package:tbcare_main/features/doctor/screens/dashboard/components/overview_stats.dart';
import 'package:tbcare_main/features/doctor/screens/dashboard/components/recent_activity.dart';
import 'package:tbcare_main/features/doctor/screens/dashboard/components/storage_details.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor, // ✅ Light dashboard background from constants
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              const Header(),
              const SizedBox(height: defaultPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        const OverviewStats(),
                        const SizedBox(height: defaultPadding),
                        const RecentActivity(),
                        if (Responsive.isMobile(context))
                          const SizedBox(height: defaultPadding),
                        if (Responsive.isMobile(context))
                          const StorageDetails(),
                      ],
                    ),
                  ),
                  if (!Responsive.isMobile(context))
                    const SizedBox(width: defaultPadding),
                  if (!Responsive.isMobile(context))
                    const Expanded(flex: 2, child: StorageDetails()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
