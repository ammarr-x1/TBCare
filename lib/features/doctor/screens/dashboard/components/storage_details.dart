import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'package:tbcare_main/features/doctor/screens/dashboard/components/chart.dart';
import 'package:tbcare_main/features/doctor/screens/dashboard/components/storageInfo_card.dart';

class StorageDetails extends StatelessWidget {
  const StorageDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white, // light background for dashboard card
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Weekly TB Detection",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
          ),
          const SizedBox(height: defaultPadding),
          const Chart(),
          StorageInfoCard(
            title: "AI-Flagged Cases",
            svgSrc: "assets/icons/brain.svg",
            value: 23,
            description: "TB suspected by AI",
          ),
          StorageInfoCard(
            title: "Manual Diagnoses",
            svgSrc: "assets/icons/check-shield.svg",
            value: 17,
            description: "Doctor-confirmed TB",
          ),
          StorageInfoCard(
            title: "Weekly Uploads",
            svgSrc: "assets/icons/clipboard.svg",
            value: 41,
            description: "New screenings this week",
          ),
          StorageInfoCard(
            title: "Cough Audio Files",
            svgSrc: "assets/icons/graph-up.svg",
            value: 29,
            description: "Audio samples uploaded",
          ),
        ],
      ),
    );
  }
}
