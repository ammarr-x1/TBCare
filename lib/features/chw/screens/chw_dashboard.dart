import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:tbcare_main/features/chw/models/chw_dashboard_patient_model.dart';
import 'package:tbcare_main/features/chw/services/chw_dashboard_service.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'chw_layout.dart';

class CHWDashboard extends StatefulWidget {
  const CHWDashboard({Key? key}) : super(key: key);

  @override
  State<CHWDashboard> createState() => _CHWDashboardState();
}

class _CHWDashboardState extends State<CHWDashboard> {
  final CHWDashboardService _service = CHWDashboardService();

  Widget _buildStatCard(String title, int value, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(largeRadius),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(largeRadius),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.bar_chart, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: secondaryColor,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return StreamBuilder<List<RecentActivity>>(
      stream: _service.recentActivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No recent activity",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final activities = snapshot.data!;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final activity = activities[index];
            final formattedDate = activity.date != null
                ? DateFormat('dd MMM yyyy').format(activity.date!)
                : "Unknown date";

            return Card(
              elevation: 1,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: primaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                title: Text(
                  activity.name,
                  style: const TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    activity.status,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

                          'referrals': 0,
                          'followUps': 0,
                          'confirmed': 0,
                          'screenings': 0,
                        };

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: [
                            FutureBuilder<int>(
                              future: _service.countPatients(),
                              builder: (context, snap) => _buildStatCard(
                                "Patients",
                                snap.data ?? 0,
                                primaryColor,
                                onTap: () => Navigator.pushNamed(
                                    context, AppConstants.patientListRoute),
                              ),
                            ),
                            _buildStatCard(
                              "Screenings",
                              counts['screenings']!,
                              successColor,
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppConstants.patientScreeningRoute);
                              },
                            ),
                            _buildStatCard(
                              "AI Flagged",
                              counts['aiFlagged']!,
                              warningColor,
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppConstants.aiFlaggedRoute);
                              },
                            ),
                            _buildStatCard(
                              "Lab Tests",
                              counts['labTestsPending'] ?? 0,
                              errorColor,
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppConstants.labTestRoute);
                              },
                            ),
                            _buildStatCard(
                              "Follow-Ups",
                              counts['followUps']!,
                              const Color(0xFF9B59B6),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppConstants.chwFollowupsRoute);
                              },
                            ),
                            _buildStatCard(
                              "Referrals",
                              counts['referrals']!,
                              const Color(0xFFF39C12),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppConstants.chwReferralsRoute);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Recent Activity Section
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.history,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Recent Activity",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- Sidebar Widget ----------
class _Sidebar extends StatelessWidget {
  final VoidCallback onLogout;
  const _Sidebar({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    Widget item(
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
            color: selected ? primaryColor : secondaryColor.withOpacity(0.7),
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
          onTap: onTap ?? () => Navigator.pop(context),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with brand
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
            
            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  item(
                    Icons.dashboard,
                    'Dashboard',
                    selected: true,
                    onTap: () {},
                  ),
                  item(
                    Icons.groups_2,
                    'Patients',
                    onTap: () {
                      Navigator.pushNamed(
                          context, AppConstants.managePatientsRoute);
                    },
                  ),
                  item(
                    Icons.medical_services_outlined,
                    'Screening & Diagnosis',
                    onTap: () {
                      Navigator.pushNamed(
                          context, AppConstants.chwScreeningRoute);
                    },
                  ),
                  item(
                    Icons.assignment_turned_in_outlined,
                    'Follow-ups',
                    onTap: () {
                      Navigator.pushNamed(
                          context, AppConstants.chwFollowupsRoute);
                    },
                  ),
                  item(
                    Icons.send_outlined,
                    'Referrals',
                    onTap: () {
                      Navigator.pushNamed(
                          context, AppConstants.chwReferralsRoute);
                    },
                  ),
                ],
              ),
            ),
            
            // Divider and Logout
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
                onTap: onLogout,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}