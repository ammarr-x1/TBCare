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
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          // Responsive Grid Logic
                          final width = constraints.maxWidth;
                          int crossAxisCount = 1;
                          double aspectRatio = 0.85; // Taller cards for mobile (1 col) 

                          if (width >= 1200) {
                            crossAxisCount = 3;
                            aspectRatio = 1.1; // Wider cards
                          } else if (width >= 800) {
                            crossAxisCount = 2;
                            aspectRatio = 0.95;
                          } else {
                            // Mobile: 1 column, but don't stretch fully if very wide mobile
                            crossAxisCount = 1;
                            aspectRatio = 1.3; // Adjust based on card content height (approximate)
                            // If AiCaseCard is dynamic height, GridView might crop it or cause overflow.
                            // Masonry is better, but without generic package, we can use a wrap or specific constraint.
                            // However, user specifically asked for "multiple cards like in a grid".
                            // To be safe with dynamic height content in a Grid, consider `childAspectRatio` carefully OR
                            // use a wrap inside a SingleChildScrollView if strict grid alignment isn't required.
                            // But GridView is requested. Let's try to be smart about aspect ratio.
                            // AiCaseCard has images (180px) + content. It's roughly 400-500px tall.
                          }
                          
                          // Allow vertical scrolling for the grid content
                          // Using a Wrap inside SingleChildScrollView is safer for variable height cards
                          // to avoid "Layout overflow" within fixed grid cells.
                          
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(largePadding),
                            child: Wrap(
                              spacing: largePadding,
                              runSpacing: largePadding,
                              children: _filteredCases.map((caseData) {
                                final cardWidth = (width - (largePadding * (crossAxisCount + 1))) / crossAxisCount;
                                return SizedBox(
                                  width: cardWidth,
                                  child: AiCaseCard(caseData: caseData),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}