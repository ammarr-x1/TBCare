import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'package:tbcare_main/features/doctor/models/patient_model.dart';
import 'package:tbcare_main/features/doctor/models/plan_item_model.dart';
import 'package:tbcare_main/features/doctor/services/diet_exercise_service.dart';


class DietPlanScreen extends StatefulWidget {
  final PatientModel patient;

  const DietPlanScreen({super.key, required this.patient});

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  Map<String, dynamic> _dietPlans = {};
  bool _isLoading = true;

  final Map<String, TextEditingController> _nameControllers = {};
  final Map<String, TextEditingController> _quantityControllers = {};

  @override
  void initState() {
    super.initState();
    _loadDietPlans();
  }

  Future<void> _loadDietPlans() async {
    setState(() => _isLoading = true);
    try {
      final plans = await DietExerciseService.fetchAllDietPlans(
        widget.patient.uid,
      );
      setState(() {
        _dietPlans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load diet plans: $e"),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  Future<void> _addItem(String timeOfDay) async {
    final name = _nameControllers[timeOfDay]?.text.trim() ?? '';
    final quantity = _quantityControllers[timeOfDay]?.text.trim() ?? '';

    if (name.isEmpty || quantity.isEmpty) return;

    final newItem = PlanItemModel(name: name, quantity: quantity);

    try {
      final docId = _dietPlans[timeOfDay]['docId'];
      await DietExerciseService.addDietItem(
        patientId: widget.patient.uid,
        planDocId: docId,
        item: newItem,
      );
      _nameControllers[timeOfDay]?.clear();
      _quantityControllers[timeOfDay]?.clear();
      await _loadDietPlans();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add item: $e"),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  Future<void> _deleteItem(String timeOfDay, PlanItemModel item) async {
    try {
      final docId = _dietPlans[timeOfDay]['docId'];
      await DietExerciseService.deleteDietItem(
        patientId: widget.patient.uid,
        planDocId: docId,
        item: item,
      );
      await _loadDietPlans();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete item: $e"),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  Future<void> _approvePlan(String timeOfDay) async {
    try {
      final docId = _dietPlans[timeOfDay]['docId'];
      await DietExerciseService.approveDietPlan(
        patientId: widget.patient.uid,
        planDocId: docId,
      );
      await _loadDietPlans();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Plan approved."),
          backgroundColor: successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to approve plan: $e"),
          backgroundColor: errorColor,
        ),
      );
    }
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
          "${widget.patient.name}'s Diet Plans",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : _dietPlans.isEmpty
          ? Center(
              child: Text(
                "No diet plans found.",
                style: TextStyle(
                  color: secondaryColor.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(defaultPadding),
              children: _dietPlans.entries.map((entry) {
                final timeOfDay = entry.key;
                final planData = entry.value;
                final List<PlanItemModel> items = List<PlanItemModel>.from(
                  planData['items'],
                );
                final bool isApproved = planData['approvedByDoctor'] ?? false;

                _nameControllers.putIfAbsent(
                  timeOfDay,
                  () => TextEditingController(),
                );
                _quantityControllers.putIfAbsent(
                  timeOfDay,
                  () => TextEditingController(),
                );

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 20),
                  elevation: 2,
                  shadowColor: primaryColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: primaryColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                planData['title'] ?? timeOfDay,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: isApproved
                                  ? null
                                  : () => _approvePlan(timeOfDay),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isApproved
                                    ? secondaryColor.withOpacity(0.3)
                                    : successColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                isApproved ? "Approved" : "Approve Plan",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...items.map(
                          (item) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  color: successColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          color: secondaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.quantity,
                                        style: TextStyle(
                                          color: secondaryColor.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    color: errorColor,
                                  ),
                                  onPressed: () => _deleteItem(timeOfDay, item),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (items.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: secondaryColor.withOpacity(0.5),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "No items added yet",
                                  style: TextStyle(
                                    color: secondaryColor.withOpacity(0.5),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Divider(
                          color: primaryColor.withOpacity(0.2),
                          height: 24,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildTextField(
                                controller: _nameControllers[timeOfDay]!,
                                hintText: "Item Name",
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                controller: _quantityControllers[timeOfDay]!,
                                hintText: "Quantity",
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: () => _addItem(timeOfDay),
                                icon: Icon(
                                  Icons.add_circle,
                                  color: successColor,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: secondaryColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: secondaryColor.withOpacity(0.5)),
        filled: true,
        fillColor: bgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}