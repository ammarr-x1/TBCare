import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';
import '../../models/patient_model.dart';
import '../../services/patient_service.dart';
import 'components/recommendation_card.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Recommendations for TB Patients",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // ignore: invalid_use_of_protected_member
              (context as Element).reassemble();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced Total TB Patients Card - Light Theme
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(defaultPadding),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  bgColor,
                  primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: StreamBuilder<List<PatientModel>>(
              stream: PatientService.fetchTBPatientsStream(),
              builder: (context, snapshot) {
                final count = snapshot.hasData ? snapshot.data!.length : 0;
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;

                return Row(
                  children: [
                    // Enhanced Icon Container - Light Theme
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryColor.withOpacity(0.1),
                            primaryColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.15),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryColor,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.medical_services_outlined,
                              color: primaryColor,
                              size: 32,
                            ),
                    ),

                    const SizedBox(width: 20),

                    // Enhanced Patient Info - Light Theme
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total TB Patients',
                            style: TextStyle(
                              color: secondaryColor.withOpacity(0.8),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                count.toString(),
                                style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  count == 1 ? 'Patient' : 'Patients',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: successColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              'Under Care',
                              style: TextStyle(
                                color: successColor.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Indicator
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: snapshot.hasError
                            ? errorColor
                            : count > 0
                            ? successColor
                            : warningColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (snapshot.hasError
                                    ? errorColor
                                    : count > 0
                                    ? successColor
                                    : warningColor)
                                .withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: StreamBuilder<List<PatientModel>>(
                stream: PatientService.fetchTBPatientsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error loading patients",
                        style: TextStyle(
                          color: errorColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.personal_injury_outlined,
                            size: 64,
                            color: secondaryColor.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No TB patients found.",
                            style: TextStyle(
                              color: secondaryColor.withOpacity(0.6),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Add patients to view recommendations",
                            style: TextStyle(
                              color: secondaryColor.withOpacity(0.4),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final tbPatients = snapshot.data!;

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: tbPatients.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: defaultPadding),
                    itemBuilder: (context, index) {
                      final patient = tbPatients[index];
                      return PatientRecommendationCard(
                        patient: patient,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}