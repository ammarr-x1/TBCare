import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:tbcare_main/features/chw/services/chw_dashboard_service.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'chw_layout.dart';

class CHWDashboard extends StatefulWidget {
  const CHWDashboard({super.key});

  @override
  State<CHWDashboard> createState() => _CHWDashboardState();
}

class _CHWDashboardState extends State<CHWDashboard> {
  late final CHWDashboardService _service;
  late final Stream<DashboardStats> _statsStream;
  late final Stream<List<RecentActivity>> _activityStream;

  @override
  void initState() {
    super.initState();
    _service = CHWDashboardService();
    // Cache streams to prevent re-subscription on rebuilds
    _statsStream = _service.dashboardStatsStream();
    _activityStream = _service.recentActivityStream(limit: 10);
  }

  @override
  Widget build(BuildContext context) {
    return ChwLayout(
      title: "Dashboard",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            _buildStatsGrid(),
            const SizedBox(height: 32),
            _buildRecentActivityHeader(),
            const SizedBox(height: 16),
            _buildRecentActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return StreamBuilder<DashboardStats>(
      stream: _statsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingIndicator();
        }

        if (snapshot.hasError) {
          return _ErrorWidget(error: snapshot.error.toString());
        }

        final stats = snapshot.data ?? const DashboardStats();

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1000
                ? 3
                : constraints.maxWidth > 600
                    ? 2
                    : 1;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _StatCard(
                  title: "Patients",
                  value: stats.patients,
                  color: primaryColor,
                  icon: Icons.people_outline,
                  onTap: () => Navigator.pushNamed(context, AppConstants.patientListRoute),
                ),
                _StatCard(
                  title: "Screenings",
                  value: stats.screenings,
                  color: successColor,
                  icon: Icons.assignment_outlined,
                  onTap: () => Navigator.pushNamed(context, AppConstants.patientScreeningRoute),
                ),
                _StatCard(
                  title: "AI Flagged",
                  value: stats.aiFlagged,
                  color: warningColor,
                  icon: Icons.flag_outlined,
                  onTap: () => Navigator.pushNamed(context, AppConstants.aiFlaggedRoute),
                ),
                _StatCard(
                  title: "Lab Tests",
                  value: stats.labTests,
                  color: errorColor,
                  icon: Icons.science_outlined,
                  onTap: () => Navigator.pushNamed(context, AppConstants.labTestRoute),
                ),
                _StatCard(
                  title: "Follow-Ups",
                  value: stats.followUps,
                  color: const Color(0xFF9B59B6),
                  icon: Icons.schedule_outlined,
                  onTap: () => Navigator.pushNamed(context, AppConstants.chwFollowupsRoute),
                ),
                _StatCard(
                  title: "Referrals",
                  value: stats.referrals,
                  color: const Color(0xFFF39C12),
                  icon: Icons.send_outlined,
                  onTap: () => Navigator.pushNamed(context, AppConstants.chwReferralsRoute),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRecentActivityHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.history, color: primaryColor, size: 20),
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
    );
  }

  Widget _buildRecentActivityList() {
    return StreamBuilder<List<RecentActivity>>(
      stream: _activityStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingIndicator();
        }

        if (snapshot.hasError) {
          return _ErrorWidget(error: snapshot.error.toString());
        }

        final activities = snapshot.data ?? [];

        if (activities.isEmpty) {
          return const _EmptyState(
            icon: Icons.assignment_outlined,
            message: "No recent activity",
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _ActivityTile(activity: activities[index]),
        );
      },
    );
  }
}

/// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(largeRadius),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(largeRadius),
            gradient: LinearGradient(
              colors: [Colors.white, color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
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
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: secondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Activity Tile Widget
class _ActivityTile extends StatelessWidget {
  final RecentActivity activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final date = activity.date != null
        ? DateFormat('dd MMM yyyy').format(activity.date!)
        : "Unknown date";

    final statusColor = activity.statusColor != null
        ? Color(activity.statusColor!)
        : Colors.grey;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.person_outline, color: primaryColor, size: 24),
        ),
        title: Text(
          activity.name,
          style: const TextStyle(
            color: secondaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                activity.status,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Text(
          date,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Loading Indicator
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(color: primaryColor),
      ),
    );
  }
}

/// Error Widget
class _ErrorWidget extends StatelessWidget {
  final String error;

  const _ErrorWidget({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              "Error loading data",
              style: TextStyle(color: Colors.red.shade600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty State Widget
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}