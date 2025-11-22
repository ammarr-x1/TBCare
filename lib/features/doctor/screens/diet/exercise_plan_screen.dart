import 'package:flutter/material.dart';
import 'package:tbcare_main/core/constants.dart';
import 'package:tbcare_main/features/doctor/models/plan_item_model.dart';
import 'package:tbcare_main/features/doctor/services/diet_exercise_service.dart';

class ExercisePlanScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const ExercisePlanScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  State<ExercisePlanScreen> createState() => _ExercisePlanScreenState();
}

class _ExercisePlanScreenState extends State<ExercisePlanScreen> {
  List<PlanItemModel> _items = [];
  String _planDocId = '';
  String _planTitle = '';
  bool _approved = false;
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _repsOrDurationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercisePlan();
  }

  Future<void> _loadExercisePlan() async {
    final result = await DietExerciseService.fetchAllExercisePlans(
      widget.patientId,
    );
    if (result != null) {
      setState(() {
        _planDocId = result['docId'];
        _planTitle = result['title'] ?? 'Exercise Plan';
        _approved = result['approvedByDoctor'] ?? false;
        _items = result['items'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _planTitle = 'New Exercise Plan';
        _isLoading = false;
      });
    }
  }

  Future<void> _addItem() async {
    if (_nameController.text.isEmpty ||
        _repsOrDurationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both exercise name and reps/duration."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final item = PlanItemModel(
      name: _nameController.text,
      quantity: _repsOrDurationController.text,
    );

    setState(() {
      _items.add(item);
      _nameController.clear();
      _repsOrDurationController.clear();
    });

    try {
      await DietExerciseService.addExerciseItem(
        patientId: widget.patientId,
        planDocId: _planDocId,
        item: item,
      );
    } catch (e) {
      setState(() {
        _items.remove(item);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add item: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteItem(PlanItemModel item) async {
    final originalItems = List<PlanItemModel>.from(_items);
    setState(() {
      _items.remove(item);
    });

    try {
      await DietExerciseService.deleteExerciseItem(
        patientId: widget.patientId,
        planDocId: _planDocId,
        item: item,
      );
    } catch (e) {
      setState(() {
        _items = originalItems;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to remove item: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _approvePlan() async {
    try {
      await DietExerciseService.approveExercisePlan(
        patientId: widget.patientId,
        planDocId: _planDocId,
      );

      setState(() {
        _approved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Exercise plan approved successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to approve plan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _planTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 0.8,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                strokeWidth: 3,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_approved)
                    _buildStatusBanner(
                      label: "This plan has been approved by a doctor.",
                      color: Colors.green,
                      icon: Icons.check_circle_outline,
                    )
                  else
                    _buildStatusBanner(
                      label: "This plan is pending approval.",
                      color: Colors.orange,
                      icon: Icons.warning_amber_rounded,
                    ),
                  const SizedBox(height: defaultPadding),

                  if (!_approved) ...[
                    Text(
                      "Add New Exercise",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Divider(
                      color: Colors.white12,
                      thickness: 1,
                      height: 20,
                    ),
                    _buildInputRow(),
                    const SizedBox(height: 25),
                  ],

                  Text(
                    "Plan Items",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(
                    color: Colors.white12,
                    thickness: 1,
                    height: 20,
                  ),
                  Expanded(
                    child: _items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fitness_center_outlined,
                                  color: Colors.white54,
                                  size: 50,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  "No exercises added yet.",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, index) {
                              final item = _items[index];
                              return _buildListItem(item, !_approved);
                            },
                          ),
                  ),

                  if (!_approved)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: defaultPadding),
                        child: ElevatedButton.icon(
                          onPressed: _approvePlan,
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Approve Exercise Plan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusBanner({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildTextField(
            controller: _nameController,
            labelText: "Exercise Name",
            hintText: "e.g., Push-ups",
          ),
        ),
        const SizedBox(width: defaultPadding),
        Expanded(
          flex: 2,
          child: _buildTextField(
            controller: _repsOrDurationController,
            labelText: "Reps / Duration",
            hintText: "e.g., 3 sets of 10",
          ),
        ),
        const SizedBox(width: defaultPadding),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _addItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white38),
        labelStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: secondaryColor.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildListItem(PlanItemModel item, bool canDelete) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: 8,
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          item.quantity,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
        trailing: canDelete
            ? IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 26,
                ),
                onPressed: () => _deleteItem(item),
                tooltip: "Remove exercise",
              )
            : null,
      ),
    );
  }
}
