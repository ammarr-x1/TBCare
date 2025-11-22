import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tbcare_main/features/chw/models/patient_list_model.dart';
import 'package:tbcare_main/features/chw/services/patient_list_service.dart';
import 'package:tbcare_main/features/chw/widgets/chw_back_button.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({Key? key}) : super(key: key);

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final PatientService _service = PatientService();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = const ['All', 'Male', 'Female', 'Other'];
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Patient> _applyFilters(List<Patient> patients) {
    final query = _searchController.text.trim().toLowerCase();
    final filter = _filters[_selectedFilterIndex];

    return patients.where((patient) {
      final gender = patient.gender.toLowerCase();
      final matchesFilter = filter == 'All' ||
          (filter == 'Other'
              ? gender != 'male' && gender != 'female'
              : gender == filter.toLowerCase());
      final matchesQuery = query.isEmpty ||
          patient.name.toLowerCase().contains(query) ||
          patient.phone.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  Future<bool?> _confirmDeletion(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red.shade400, size: 26),
            const SizedBox(width: 8),
            Text(
              "Delete Patient",
              style: TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          "This action cannot be undone. Do you want to continue?",
          style: TextStyle(
            color: secondaryColor.withOpacity(0.85),
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePatient(BuildContext context, Patient patient) async {
    final confirm = await _confirmDeletion(context);
    if (confirm == true) {
      await _service.deletePatient(patient.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Patient deleted"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _openPatientDetails(BuildContext context, String patientId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientDetailScreen(
          chwId: _service.chwId,
          patientId: patientId,
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: primaryColor.withOpacity(0.7)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search patients by name or phone',
                border: InputBorder.none,
                hintStyle: TextStyle(color: secondaryColor.withOpacity(0.6)),
              ),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              color: secondaryColor,
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = index == _selectedFilterIndex;
          return ChoiceChip(
            label: Text(
              filter,
              style: TextStyle(
                color: selected ? bgColor : secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: selected,
            selectedColor: primaryColor,
            backgroundColor: Colors.white,
            onSelected: (value) {
              if (value) {
                setState(() {
                  _selectedFilterIndex = index;
                });
              }
            },
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: _filters.length,
      ),
    );
  }

  Widget _buildSummaryStats(List<Patient> patients) {
    final total = patients.length;
    final male = patients
        .where((patient) => patient.gender.toLowerCase() == 'male')
        .length;
    final female = patients
        .where((patient) => patient.gender.toLowerCase() == 'female')
        .length;
    final other = (total - male - female).clamp(0, total);

    final stats = [
      _StatData(
        label: 'Total',
        value: total,
        icon: Icons.groups_rounded,
        color: primaryColor,
      ),
      _StatData(
        label: 'Male',
        value: male,
        icon: Icons.male,
        color: Colors.blueAccent,
      ),
      _StatData(
        label: 'Female',
        value: female,
        icon: Icons.female,
        color: Colors.pinkAccent,
      ),
      _StatData(
        label: 'Other',
        value: other,
        icon: Icons.account_circle,
        color: Colors.teal,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        final cardWidth = isNarrow
            ? constraints.maxWidth
            : (constraints.maxWidth - 42) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: stats.map((stat) {
            return SizedBox(
              width: isNarrow ? double.infinity : cardWidth,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      stat.color.withOpacity(0.2),
                      stat.color.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: stat.color.withOpacity(0.25),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(stat.icon, color: stat.color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat.label,
                          style: TextStyle(
                            color: secondaryColor.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          stat.value.toString(),
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPatientCollection(List<Patient> patients) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isGrid = constraints.maxWidth > 900;
        if (isGrid) {
          final crossAxisCount = math.max(1, constraints.maxWidth ~/ 360);
          return GridView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 3.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 18,
            ),
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return _buildPatientCard(
                context,
                patient,
                () => _openPatientDetails(context, patient.id),
                () => _deletePatient(context, patient),
              );
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: _buildPatientCard(
                context,
                patient,
                () => _openPatientDetails(context, patient.id),
                () => _deletePatient(context, patient),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPatientCard(
    BuildContext context,
    Patient patient,
    VoidCallback onTap,
    VoidCallback onDelete,
  ) {
    final shortId = patient.id.length > 6 ? patient.id.substring(0, 6) : patient.id;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.12),
              bgColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.15),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Hero(
                  tag: patient.id,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: primaryColor.withOpacity(0.25),
                    child: Icon(Icons.person, color: primaryColor, size: 30),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ID: $shortId',
                        style: TextStyle(
                          color: secondaryColor.withOpacity(0.75),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: secondaryColor.withOpacity(0.15),
                            ),
                            child: Text(
                              patient.gender,
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.phone_android,
                            size: 16,
                            color: secondaryColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              patient.phone,
                              style: TextStyle(
                                color: secondaryColor.withOpacity(0.85),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios,
                          color: primaryColor, size: 20),
                      tooltip: 'View Patient Details',
                      onPressed: onTap,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: Colors.red.shade400),
                      tooltip: 'Delete Patient',
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.35),
                  primaryColor.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.all(30),
            child: Icon(Icons.person_add_alt, color: primaryColor, size: 64),
          ),
          const SizedBox(height: 24),
          Text(
            "No patients yet",
            style: TextStyle(
              color: secondaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Register a patient to start tracking their journey. They'll show up instantly in this space.",
              style: TextStyle(
                color: secondaryColor.withOpacity(0.7),
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    final query = _searchController.text.trim();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: secondaryColor.withOpacity(0.4)),
          const SizedBox(height: 14),
          Text(
            query.isEmpty ? "Nothing to show" : "No matches for \"$query\"",
            style: TextStyle(
              color: secondaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your filters or search term.",
            style: TextStyle(
              color: secondaryColor.withOpacity(0.75),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget errorState(String? errorMsg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade50, Colors.red.shade100],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700, size: 42),
              const SizedBox(height: 12),
              Text(
                "Something went wrong",
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                errorMsg ?? 'Please try again later or check your connection.',
                style: TextStyle(
                  color: secondaryColor.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const ChwBackButton(iconColor: bgColor),
        title: const Text(
          "My Patients",
          style: TextStyle(
            color: bgColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 7,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [bgColor, bgColor.withOpacity(0.96)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                  const SizedBox(height: 18),
                  Expanded(
                    child: StreamBuilder<List<Patient>>(
                      stream: _service.getPatients(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                              strokeWidth: 4,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return errorState(snapshot.error.toString());
                        }

                        final patients = snapshot.data ?? [];
                        if (patients.isEmpty) {
                          return emptyState();
                        }

                        final filteredPatients = _applyFilters(patients);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSummaryStats(patients),
                            const SizedBox(height: 12),
                            Text(
                              'Showing ${filteredPatients.length} of ${patients.length} patients',
                              style: TextStyle(
                                color: secondaryColor.withOpacity(0.75),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              child: filteredPatients.isEmpty
                                  ? _buildNoResults()
                                  : _buildPatientCollection(filteredPatients),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}
