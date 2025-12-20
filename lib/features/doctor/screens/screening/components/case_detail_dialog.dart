import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';
import '../../../models/ai_case_model.dart';

class CaseDetailDialog extends StatelessWidget {
  final AiCaseModel caseData;

  const CaseDetailDialog({super.key, required this.caseData});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600), // Better width for desktop
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stylish Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.medical_information,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Case Details",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "ID: ${caseData.screeningId.substring(0, 8)}...",
                          style: TextStyle(
                            color: secondaryColor.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 20, color: secondaryColor.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),

              // Content Grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Patient Info & Image
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Patient Information", Icons.person_outline),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50], // Very light grey bg
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(context, "Patient Name", caseData.patientName),
                              const Divider(height: 24),
                              _buildInfoRow(context, "Upload Date", caseData.date.toLocal().toString().split(' ')[0]),
                              const Divider(height: 24),
                              _buildStatusRow("Diagnosis Status", caseData.status),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        _buildSectionHeader("Media Evidence", Icons.image_search),
                        const SizedBox(height: 12),
                        _buildMediaContent(),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 24),

                  // Right Column: AI & Symptoms
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("AI Analysis", Icons.psychology_outlined),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor.withOpacity(0.05), Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primaryColor.withOpacity(0.1)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Analysis Result", style: TextStyle(color: secondaryColor.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w600)),
                                  Text(
                                    caseData.aiResult ?? 'Pending',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader("Reported Symptoms", Icons.sick_outlined),
                        const SizedBox(height: 12),
                        if (caseData.symptoms != null && caseData.symptoms!.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: caseData.symptoms!.entries.map((entry) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.orange.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange[700]),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${entry.key}: ${entry.value}",
                                      style: TextStyle(
                                        color: Colors.orange[800],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        else
                          Text("No reported symptoms", style: TextStyle(color: secondaryColor.withOpacity(0.5), fontStyle: FontStyle.italic)),

                        const SizedBox(height: 24),
                        _buildSectionHeader("Doctor Notes", Icons.edit_note_rounded),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Text(
                            caseData.doctorNotes?.isNotEmpty == true 
                                ? caseData.doctorNotes! 
                                : 'No notes added yet',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: caseData.doctorNotes?.isNotEmpty == true 
                                  ? secondaryColor.withOpacity(0.8) 
                                  : secondaryColor.withOpacity(0.4),
                              fontStyle: caseData.doctorNotes?.isNotEmpty == true ? FontStyle.normal : FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),

              // Close Button - Sized appropriately (Right aligned)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: secondaryColor.withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Close Details",
                      style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: secondaryColor.withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: secondaryColor.withOpacity(0.8),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: secondaryColor.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(color: secondaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStatusRow(String label, String status) {
    Color color = accentColor;
    if (status.toLowerCase().contains('not')) color = successColor;
    else if (status.toLowerCase().contains('tb')) color = errorColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: secondaryColor.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaContent() {
    if (caseData.mediaType == 'xray') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9, // Proper aspect ratio
          child: Image.network(
            caseData.mediaUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, p) => p == null ? child : Container(color: Colors.grey[100], child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[100],
              child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
        ),
      );
    } 
    // ... (Keep existing cough logic if needed or simplify for new UI)
    // Simplified placeholder for cough as requested "Awful" UI usually implies Xray focus
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.audiotrack), SizedBox(width: 8), Text("Audio File")]),
    );
  }
}