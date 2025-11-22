import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'package:tbcare_main/features/doctor/models/patient_model.dart';
import 'package:tbcare_main/features/doctor/models/recommendation_model.dart';
import 'package:tbcare_main/features/doctor/services/recommendation_service.dart';
import 'components/add_recommendation_form.dart';
import 'components/recommendation_list_item.dart';
import 'components/empty_state_widget.dart';

class RecommendationDetailScreen extends StatefulWidget {
  final PatientModel patient;

  const RecommendationDetailScreen({super.key, required this.patient});

  @override
  State<RecommendationDetailScreen> createState() =>
      _RecommendationDetailScreenState();
}

class _RecommendationDetailScreenState
    extends State<RecommendationDetailScreen> {
  final TextEditingController _medicalController = TextEditingController();
  final TextEditingController _lifestyleController = TextEditingController();

  bool isSubmitting = false;

  // JAB AUTH HOGA TOU YEH HARDCODED ID REPLACE KRNI
  final String doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _submitRecommendation() async {
    final medical = _medicalController.text.trim();
    final lifestyle = _lifestyleController.text.trim();

    if (medical.isEmpty && lifestyle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Enter at least one recommendation"),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await RecommendationService.addRecommendation(
        patientId: widget.patient.uid,
        doctorId: doctorId,
        medicalAdvice: medical,
        lifestyleAdvice: lifestyle,
      );

      _medicalController.clear();
      _lifestyleController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Recommendation added"),
          backgroundColor: successColor,
        ),
      );
    } catch (e) {
      debugPrint("Error adding recommendation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to save recommendation"),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Recommendations - ${widget.patient.name}",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddRecommendationForm(
              medicalController: _medicalController,
              lifestyleController: _lifestyleController,
              isSubmitting: isSubmitting,
              onSubmit: _submitRecommendation,
            ),
            const SizedBox(height: defaultPadding),

            // ✅ Fetch latest screening and show recs
            Expanded(
              child: FutureBuilder<String?>(
                future: RecommendationService.fetchLatestScreeningId(
                  widget.patient.uid,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const EmptyStateWidget(
                      icon: Icons.assessment_outlined,
                      title: "No screenings found",
                      subtitle: "Complete a screening first",
                    );
                  }

                  final screeningId = snapshot.data!;

                  return StreamBuilder<List<RecommendationModel>>(
                    stream: RecommendationService.fetchRecommendations(
                      widget.patient.uid,
                      screeningId,
                    ),
                    builder: (context, recSnapshot) {
                      if (recSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        );
                      }
                      if (!recSnapshot.hasData || recSnapshot.data!.isEmpty) {
                        return const EmptyStateWidget(
                          icon: Icons.recommend_outlined,
                          title: "No recommendations yet",
                          subtitle: "Add your first recommendation above",
                        );
                      }

                      final recs = recSnapshot.data!;

                      return ListView.separated(
                        itemCount: recs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final rec = recs[index];
                          return RecommendationListItem(
                            recommendation: rec,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}