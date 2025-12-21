import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'package:tbcare_main/features/doctor/models/patient_model.dart';
import 'package:tbcare_main/features/doctor/services/doctor_service.dart';
import 'package:tbcare_main/features/doctor/services/patient_service.dart';
import 'package:tbcare_main/features/doctor/screens/dashboard/components/chart.dart';

class StorageDetails extends StatefulWidget {
  const StorageDetails({super.key});

  @override
  State<StorageDetails> createState() => _StorageDetailsState();
}

class _StorageDetailsState extends State<StorageDetails> {
  bool isLoading = true;
  Map<int, int> weeklyDiagnoses = {};
  Map<String, int> patientStatusCounts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    // Fetch parallel data
    try {
      final weekly = await DoctorService.fetchWeeklyDiagnoses();
      final patients = await PatientService.fetchAllPatients(); // This is just a fetch, not stream

      // Process patient stats
      final stats = <String, int>{
        'TB': 0,
        'Not TB': 0,
        'TB Likely': 0,
        'Other': 0,
      };

      for (var p in patients) {
        final status = p.diagnosisStatus;
        if (stats.containsKey(status)) {
          stats[status] = (stats[status] ?? 0) + 1;
        } else {
          stats['Other'] = (stats['Other'] ?? 0) + 1;
        }
      }

      if (mounted) {
        setState(() {
          weeklyDiagnoses = weekly;
          patientStatusCounts = stats;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading charts data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: isLoading 
        ? const SizedBox(
            height: 300, 
            child: Center(child: CircularProgressIndicator())
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chart(weeklyData: weeklyDiagnoses),
              const SizedBox(height: defaultPadding),
              
              // Patient Status Pie Chart
              Text(
                "Patient Status",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: defaultPadding),
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        startDegreeOffset: -90,
                        sections: _buildPieSections(),
                      ),
                    ),
                    Center(
                      child: Text(
                        "${patientStatusCounts.values.fold(0, (a, b) => a + b)}",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: defaultPadding),
              _buildLegend(context),
            ],
          ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    // If no data, show a placeholder grey ring
    final total = patientStatusCounts.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey[200],
          value: 1,
          showTitle: false,
          radius: 25,
        ),
      ];
    }

    return [
      if ((patientStatusCounts['TB'] ?? 0) > 0)
        PieChartSectionData(
          color: errorColor,
          value: (patientStatusCounts['TB'] ?? 0).toDouble(),
          title: "${patientStatusCounts['TB']}",
          radius: 25,
          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      if ((patientStatusCounts['TB Likely'] ?? 0) > 0)
        PieChartSectionData(
          color: warningColor,
          value: (patientStatusCounts['TB Likely'] ?? 0).toDouble(),
          title: "${patientStatusCounts['TB Likely']}",
          radius: 25,
          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      if ((patientStatusCounts['Not TB'] ?? 0) > 0)
        PieChartSectionData(
          color: successColor,
          value: (patientStatusCounts['Not TB'] ?? 0).toDouble(),
          title: "${patientStatusCounts['Not TB']}",
          radius: 25,
          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      if ((patientStatusCounts['Other'] ?? 0) > 0)
        PieChartSectionData(
          color: accentColor,
          value: (patientStatusCounts['Other'] ?? 0).toDouble(),
          title: "${patientStatusCounts['Other']}",
          radius: 25,
          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
    ];
  }

  Widget _buildLegend(BuildContext context) {
    return Column(
      children: [
        _legendItem(color: errorColor, text: "Confirmed TB"),
        _legendItem(color: warningColor, text: "TB Likely"),
        _legendItem(color: successColor, text: "Not TB"),
        _legendItem(color: accentColor, text: "Other/Pending"),
      ],
    );
  }

  Widget _legendItem({required Color color, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: secondaryColor, fontSize: 13)),
        ],
      ),
    );
  }
}
