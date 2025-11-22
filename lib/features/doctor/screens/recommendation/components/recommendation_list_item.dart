import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'package:tbcare_main/features/doctor/models/recommendation_model.dart';

class RecommendationListItem extends StatelessWidget {
  final RecommendationModel recommendation;

  const RecommendationListItem({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: secondaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        side: BorderSide(
          color: secondaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Medical",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
                Text(
                  recommendation.createdAt.toString().split(' ')[0],
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              recommendation.medicalAdvice.isNotEmpty
                  ? recommendation.medicalAdvice
                  : "No medical advice",
              style: TextStyle(
                fontSize: 14,
                color: secondaryColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),

            // Lifestyle
            Text(
              "Lifestyle",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              recommendation.lifestyleAdvice.isNotEmpty
                  ? recommendation.lifestyleAdvice
                  : "No lifestyle advice",
              style: TextStyle(
                fontSize: 14,
                color: secondaryColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),

            // Footer
            Text(
              "By: ${recommendation.addedBy}",
              style: TextStyle(
                fontSize: 12,
                color: secondaryColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}