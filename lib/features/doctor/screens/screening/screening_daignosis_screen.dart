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
  List<AiCaseModel> _allCases = [];
  List<AiCaseModel> _filteredCases = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchScreeningCases();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCases = List.from(_allCases);
      } else {
        _filteredCases = _allCases.where((caseData) {
          return caseData.patientName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> fetchScreeningCases() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final fetched = await ScreeningService.fetchAiCasesForDoctorDashboard();
      if (!mounted) return;
      setState(() {
        _allCases = fetched;
        _filteredCases = fetched;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching cases: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor, // Use standard background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          "Screening & Diagnosis",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white, // White text on primary color
                fontWeight: FontWeight.w700,
              ),
        ),
        backgroundColor: primaryColor, // Required by user
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), // Semi-transparent white
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
            ),
            onPressed: fetchScreeningCases,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search Bar Section - Keep it clean but on primary/bg boundary
          Container(
            color: bgColor,
            padding: const EdgeInsets.fromLTRB(largePadding, largePadding, largePadding, smallPadding),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search by patient name...",
                  hintStyle: TextStyle(color: secondaryColor.withOpacity(0.4)),
                  prefixIcon: Icon(Icons.search, color: secondaryColor.withOpacity(0.4)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: secondaryColor.withOpacity(0.4)),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryColor))
                : _filteredCases.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _allCases.isEmpty
                                  ? Icons.assignment_outlined
                                  : Icons.search_off,
                              size: 64,
                              color: secondaryColor.withOpacity(0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _allCases.isEmpty
                                  ? "No screenings found"
                                  : "No patients found matching '${_searchController.text}'",
                              style: TextStyle(
                                color: secondaryColor.withOpacity(0.5),
                                fontSize: bodySize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(largePadding),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 1100
                              ? 3
                              : MediaQuery.of(context).size.width > 700
                                  ? 2
                                  : 1,
                          crossAxisSpacing: largePadding,
                          mainAxisSpacing: largePadding,
                          childAspectRatio: 0.6,
                        ),
                        itemCount: _filteredCases.length,
                        itemBuilder: (context, index) {
                          return AiCaseCard(caseData: _filteredCases[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}