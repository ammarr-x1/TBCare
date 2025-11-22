import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tbcare_main/features/chw/models/flagged_patients_model.dart';
import 'package:tbcare_main/features/chw/services/flagged_patients_service.dart';
import 'package:tbcare_main/features/chw/widgets/chw_back_button.dart';
import 'package:tbcare_main/core/app_constants.dart';

class FlaggedPatientsScreen extends StatelessWidget {
  const FlaggedPatientsScreen({super.key});

  String _getAiResult(Screening s) {
    if (s.aiPrediction == null || s.aiPrediction.isEmpty) return "pending";

    if (s.aiPrediction is String) {
      final str = s.aiPrediction as String;
      if (str.toLowerCase() != 'pending' && str.toLowerCase() != 'unknown') {
        return str;
      }
      return "pending";
    }

    if (s.aiPrediction is Map<String, dynamic>) {
      final map = s.aiPrediction as Map<String, dynamic>;
      final tbProb = double.tryParse(map["TB"]?.toString() ?? "0") ?? 0.0;
      final normalProb = double.tryParse(map["Normal"]?.toString() ?? "0") ?? 0.0;
      if (tbProb == 0 && normalProb == 0) return "pending";
      return tbProb >= normalProb ? "TB" : "Normal";
    }

    return "pending";
  }

  @override
  Widget build(BuildContext context) {
    final service = ScreeningService();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const ChwBackButton(iconColor: Colors.white),
        title: const Text("AI-Flagged TB Patients",
            style: TextStyle(color: Colors.white)),
        backgroundColor: secondaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Screening>>(
        stream: service.getAllScreenings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("✅ No pending follow-ups",
                  style: TextStyle(color: Colors.white)),
            );
          }

          final screenings = snapshot.data!;

          return ListView.builder(
            itemCount: screenings.length,
            itemBuilder: (context, index) {
              final s = screenings[index];
              return Card(
                color: secondaryColor,
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.person, color: primaryColor),
                  title: Text(
                    s.patientName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "AI Result: ${_getAiResult(s)}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FlaggedPatientDetailScreen(screening: s, service: service),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// --------------------
/// DETAIL SCREEN
/// --------------------
class FlaggedPatientDetailScreen extends StatefulWidget {
  final Screening screening;
  final ScreeningService service;

  const FlaggedPatientDetailScreen({
    super.key,
    required this.screening,
    required this.service,
  });

  @override
  State<FlaggedPatientDetailScreen> createState() =>
      _FlaggedPatientDetailScreenState();
}

class _FlaggedPatientDetailScreenState
    extends State<FlaggedPatientDetailScreen> {
  bool _isActioned = false;

  @override
  void initState() {
    super.initState();
    _checkActionStatus();
  }

  /// 🔹 Check Firestore for follow-up or referral status
  Future<void> _checkActionStatus() async {
    final doc = await FirebaseFirestore.instance
        .collection("screenings")
        .doc(widget.screening.id)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      final status = data['followUpStatus'] ?? "";
      final referred = data['referred'] ?? false;

      setState(() {
        _isActioned = status == "sent_to_doctor" || referred == true;
      });
    }
  }

  String _getAiResult(Screening s) {
    if (s.aiPrediction is String) {
      final str = s.aiPrediction as String;
      if (str.toLowerCase() != 'pending' && str.toLowerCase() != 'unknown') {
        return str;
      }
      return "pending";
    }

    if (s.aiPrediction is Map<String, dynamic>) {
      final map = s.aiPrediction as Map<String, dynamic>;
      final tbProb = double.tryParse(map["TB"]?.toString() ?? "0") ?? 0.0;
      final normalProb = double.tryParse(map["Normal"]?.toString() ?? "0") ?? 0.0;
      return tbProb >= normalProb ? "TB" : "Normal";
    }

    return "pending";
  }

  Future<void> _sendToDoctor() async {
    setState(() => _isActioned = true);
    await widget.service.sendToDoctor(widget.screening);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Sent to Doctor")),
      );
    }
  }

  Future<void> _referToHospital() async {
    setState(() => _isActioned = true);
    await widget.service.referToHospital(widget.screening);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📤 Referred to Hospital")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const ChwBackButton(iconColor: Colors.white),
        title: Text(widget.screening.patientName,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: secondaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "AI Result: ${_getAiResult(widget.screening)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text("Symptoms:", style: TextStyle(color: Colors.white70)),
            ...widget.screening.symptoms
                .map((s) => Text("• $s", style: const TextStyle(color: Colors.white))),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.send, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, foregroundColor: Colors.white),
                  onPressed: _isActioned ? null : _sendToDoctor,
                  label: const Text("Send to Doctor"),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.local_hospital, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  onPressed: _isActioned ? null : _referToHospital,
                  label: const Text("Refer to Hospital"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
