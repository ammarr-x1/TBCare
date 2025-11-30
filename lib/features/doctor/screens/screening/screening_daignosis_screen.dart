import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';
import '../../models/ai_case_model.dart';
import 'components/ai_case_card.dart';
import '../../services/screening_service.dart';

class ScreeningDiagnosisScreen extends StatefulWidget {
  const ScreeningDiagnosisScreen({super.key});

  @override
  State<ScreeningDiagnosisScreen> createState() =>
      _ScreeningDiagnosisScreenState();
}

class _ScreeningDiagnosisScreenState extends State<ScreeningDiagnosisScreen> {
  List<AiCaseModel> caseList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchScreeningCases();
  }

  Future<void> fetchScreeningCases() async {
    if(!mounted) return;
    setState(() => isLoading = true);
    try {
      final fetched = await ScreeningService.fetchAiCasesForDoctorDashboard();
      if (!mounted) return;
      setState(() {
        caseList = fetched;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching cases: $e");
      if(!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Screening & Diagnosis",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white), 
            onPressed: fetchScreeningCases,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: largePadding, vertical: defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recent AI-Screened Cases",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: defaultPadding),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: primaryColor))
                  : caseList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: secondaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No relevant screenings found.",
                            style: TextStyle(
                              color: secondaryColor.withOpacity(0.7),
                              fontSize: bodySize,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: defaultPadding),
                      itemCount: caseList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: defaultPadding),
                      itemBuilder: (context, index) =>
                          AiCaseCard(caseData: caseList[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}