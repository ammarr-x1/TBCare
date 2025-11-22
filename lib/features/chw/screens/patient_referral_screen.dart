import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tbcare_main/features/chw/models/patient_referral_model.dart';
import 'package:tbcare_main/features/chw/services/patient_referral_service.dart';
import 'package:tbcare_main/features/chw/widgets/chw_back_button.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as dev;

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final _service = ReferralService();
  String locationMessage = 'Tap the button to find nearby TB hospitals.';

  final String chwId = FirebaseAuth.instance.currentUser?.uid ?? "";

  /// 🔹 Open Google Maps directly
  Future<void> _openMaps() async {
    dev.log("User tapped 'Locate Nearby TB Hospitals'", name: "ReferralScreen");

    final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/tb+hospitals+near+me",
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        setState(() => locationMessage = "Could not open Google Maps.");
      }
    } catch (e) {
      dev.log(
        "Unexpected error while opening Google Maps: $e",
        name: "ReferralScreen",
      );
      setState(() => locationMessage = "Error opening Google Maps.");
    }
  }

  /// 🔹 Update referral status
  Future<void> _updateReferralStatus(String id, String newStatus) async {
    try {
      await _service.updateReferralStatus(id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Referral updated to $newStatus")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const ChwBackButton(iconColor: Colors.white),
        title: const Text("Referrals", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          /// 🔹 Referrals List
          Expanded(
            child: StreamBuilder<List<Referral>>(
              stream: _service.getAllReferrals(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Error loading referrals",
                      style: TextStyle(color: errorColor),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No referrals yet",
                      style: TextStyle(color: warningColor),
                    ),
                  );
                }

                final referrals = snapshot.data!;
                return ListView.builder(
                  itemCount: referrals.length,
                  itemBuilder: (context, index) {
                    final r = referrals[index];
                    return Card(
                      color: secondaryColor.withOpacity(0.6),
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          r.patientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: bgColor,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Referral Status: ${r.status}",
                              style: TextStyle(color: bgColor.withOpacity(0.8)),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          color: primaryColor.withOpacity(0.9),
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          onSelected: (value) =>
                              _updateReferralStatus(r.id, value),
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'pending',
                              child: Text(
                                'Pending',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'seen',
                              child: Text(
                                'Seen by Doctor',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'completed',
                              child: Text(
                                'Completed',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// 🔹 Hospital Locator Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 15, 141, 103),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: primaryColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  locationMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: bgColor),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.location_on),
                  label: const Text('Locate Nearby TB Hospitals'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _openMaps,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
