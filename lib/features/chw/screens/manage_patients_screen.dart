import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tbcare_main/features/chw/models/manage_patient_model.dart';
import 'package:tbcare_main/features/chw/services/manage_patient_service.dart';
import 'package:tbcare_main/features/chw/widgets/chw_back_button.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'patient_list_screen.dart';

class ManagePatientsScreen extends StatefulWidget {
  const ManagePatientsScreen({Key? key}) : super(key: key);

  @override
  _ManagePatientsScreenState createState() => _ManagePatientsScreenState();
}

class _ManagePatientsScreenState extends State<ManagePatientsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _comorbiditiesController = TextEditingController();
  final TextEditingController _medicationHistoryController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _selectedGender = "Male";
  String _selectedAppetite = "Normal";
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PatientService _patientService = PatientService();

  static const Color textColor = Colors.black;
  final _formKey = GlobalKey<FormState>();

  Future<void> _addPatient() async {
    setState(() => _isLoading = true);

    try {
      final chwId = _auth.currentUser!.uid;
      final now = DateTime.now();

      // generate a Firestore doc id for uid
      final newPatientId = _patientService.newPatientId(chwId);

      final patient = Patient(
        id: newPatientId,
        patientId: newPatientId,
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        gender: _selectedGender,
        phone: _phoneController.text.trim(),
        weight: int.tryParse(_weightController.text.trim()) ?? 0,
        comorbidities: _comorbiditiesController.text.trim(),
        medicationHistory: _medicationHistoryController.text.trim(),
        appetite: _selectedAppetite,
        createdBy: chwId,
        chwName: "Unknown CHW",
        createdAt: now,
        updatedAt: now,
        language: "English",
        symptoms: {},
        imageUrl: null,
        diagnosisStatus: "Pending",
        address: _addressController.text.trim(),
      );

      await _patientService.addPatient(patient, chwId);

      _showMessage("Patient added successfully!");

      _nameController.clear();
      _ageController.clear();
      _phoneController.clear();
      _weightController.clear();
      _comorbiditiesController.clear();
      _medicationHistoryController.clear();
      _addressController.clear();

      setState(() {
        _selectedGender = "Male";
        _selectedAppetite = "Normal";
      });
    } catch (e) {
      _showMessage("Error: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const ChwBackButton(iconColor: bgColor),
        title: const Text("Manage Patients", style: TextStyle(color: bgColor)),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: bgColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: bgColor),
            tooltip: "View Patients",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PatientListScreen()),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth < 800 ? double.infinity : 650,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Personal Information"),
                        _buildTextField(
                          _nameController,
                          "Patient Name",
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return "Name is required";
                            return null;
                          },
                        ),
                        _buildTextField(
                          _ageController,
                          "Age",
                          inputType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return "Age is required";
                            final n = int.tryParse(value);
                            if (n == null || n < 0 || n > 120) return "Enter a valid age";
                            return null;
                          },
                        ),
                        _buildDropdown(
                          "Gender",
                          ["Male", "Female", "Other"],
                          _selectedGender,
                          (val) => setState(() => _selectedGender = val!),
                        ),
                        _buildTextField(
                          _weightController,
                          "Weight (kg)",
                          inputType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return null;
                            final n = int.tryParse(value);
                            if (n != null && (n < 2 || n > 500)) return "Enter valid weight";
                            if (value.isNotEmpty && n == null) return "Enter a number";
                            return null;
                          },
                        ),
                        _buildTextField(
                          _addressController,
                          "Address",
                          validator: (value) {
                            // Optional, add logic if address should be required
                            return null;
                          },
                        ),
                        const SizedBox(height: largePadding),
                        _buildSectionTitle("Contact Details"),
                        _buildTextField(
                          _phoneController,
                          "Phone",
                          inputType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return "Phone is required";
                            if (!RegExp(r'^\d{10,15}$').hasMatch(value)) return "Enter a valid phone";
                            return null;
                          },
                        ),
                        const SizedBox(height: largePadding),
                        _buildSectionTitle("Medical History"),
                        _buildTextField(_comorbiditiesController, "Comorbidities"),
                        _buildTextField(_medicationHistoryController, "Medication History"),
                        _buildDropdown(
                          "Appetite",
                          ["Low", "Normal", "High"],
                          _selectedAppetite,
                          (val) => setState(() => _selectedAppetite = val!),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(color: primaryColor)
                              : ElevatedButton.icon(
                                  icon: const Icon(Icons.add),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: bgColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _addPatient();
                                    }
                                  },
                                  label: const Text("Add Patient"),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        style: const TextStyle(color: textColor),
        cursorColor: primaryColor,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: secondaryColor),
          filled: true,
          fillColor: bgColor.withOpacity(0.2),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String value,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: primaryColor,
        style: const TextStyle(color: Color.fromARGB(255, 195, 199, 201)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: secondaryColor),
          filled: true,
          fillColor: bgColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: largePadding),
        Text(
          title,
          style: const TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(height: 2, width: 60, color: primaryColor),
        const SizedBox(height: smallPadding),
      ],
    );
  }
}
