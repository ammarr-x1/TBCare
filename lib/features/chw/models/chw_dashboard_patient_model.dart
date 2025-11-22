class RecentActivity {
  final String name;
  final String status;
  final DateTime? date;
  final int? screenings;
  final int? followUps;
  final int? referrals;

  final int? confirmed;
  final int? aiFlagged;

  final int? patients;

  final int? total;

  final int? completed;

  final int? pending;

  final dynamic statusColor; // keep dynamic since UI assigns Color

  RecentActivity({
    required this.name,
    required this.status,
    this.date,
    this.statusColor,
    this.patients,
    this.screenings,
    this.followUps,
    this.referrals,
    this.confirmed,
    this.aiFlagged,
    this.total,
    this.completed,
    this.pending,
  });

  factory RecentActivity.fromMap(Map<String, dynamic> data) {
    return RecentActivity(
      name: data['name'] ?? 'Unknown',
      status: data['status'] ?? 'New (Not Screened)',
      date: data['date'],
      statusColor: data['statusColor'],
    );
  }
}
