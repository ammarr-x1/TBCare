import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';

class AddRecommendationForm extends StatelessWidget {
  final TextEditingController medicalController;
  final TextEditingController lifestyleController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const AddRecommendationForm({
    super.key,
    required this.medicalController,
    required this.lifestyleController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shadowColor: primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(largeRadius),
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
            TextField(
              controller: medicalController,
              maxLines: 2,
              style: TextStyle(color: secondaryColor),
              decoration: InputDecoration(
                labelText: "Medical Advice",
                labelStyle: TextStyle(color: secondaryColor.withOpacity(0.7)),
                filled: true,
                fillColor: bgColor,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lifestyleController,
              maxLines: 2,
              style: TextStyle(color: secondaryColor),
              decoration: InputDecoration(
                labelText: "Lifestyle Advice",
                labelStyle: TextStyle(color: secondaryColor.withOpacity(0.7)),
                filled: true,
                fillColor: bgColor,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : onSubmit,
                icon: const Icon(Icons.check),
                label: isSubmitting
                    ? const Text("Saving...")
                    : const Text("Add Recommendation"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: secondaryColor.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}