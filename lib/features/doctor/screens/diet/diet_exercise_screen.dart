import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'package:tbcare_main/features/doctor/models/patient_model.dart';
import 'package:tbcare_main/features/doctor/screens/diet/components/diet_exercise_card.dart';
import 'package:tbcare_main/features/doctor/screens/diet/diet_plan_screen.dart';
import 'package:tbcare_main/features/doctor/screens/diet/exercise_plan_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DietExerciseScreen extends StatefulWidget {
  const DietExerciseScreen({super.key});

  @override
  State<DietExerciseScreen> createState() => _DietExerciseScreenState();
}

class _DietExerciseScreenState extends State<DietExerciseScreen> {
  late Future<List<PatientModel>> _tbPatientsFuture;

  Future<List<PatientModel>> _fetchTBPatients() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('patients')
        .where('diagnosisStatus', isEqualTo: 'TB')
        .get();

    return snapshot.docs
        .map((doc) => PatientModel.fromMap(doc.data()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _tbPatientsFuture = _fetchTBPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Diet & Exercise Plans",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 0.8,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<PatientModel>>(
        future: _tbPatientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Loading Patient Data...",
                    style: TextStyle(
                      color: secondaryColor.withOpacity(0.6),
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: errorColor, size: 60),
                  const SizedBox(height: 20),
                  Text(
                    "Error fetching patients: \n${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: errorColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _tbPatientsFuture = _fetchTBPatients();
                      });
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      "Try Again",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    color: secondaryColor.withOpacity(0.3),
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No TB Confirmed Patients Found.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryColor.withOpacity(0.6),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final patients = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(defaultPadding),
            itemCount: patients.length,
            separatorBuilder: (_, __) => const SizedBox(height: defaultPadding),
            itemBuilder: (context, index) {
              final patient = patients[index];
              return DietExerciseCard(
                patient: patient,
                onDietTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DietPlanScreen(patient: patient),
                    ),
                  );
                },
                onExerciseTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExercisePlanScreen(
                        patientId: patient.uid,
                        patientName: patient.name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}