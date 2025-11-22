import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';
import '../../../models/ai_case_model.dart';

class CaseDetailDialog extends StatelessWidget {
  final AiCaseModel caseData;

  const CaseDetailDialog({super.key, required this.caseData});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 10,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medical_information,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Case Details",
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: secondaryColor.withOpacity(0.6)),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),

              // Patient Info Section
              _buildSection(
                "Patient Information",
                Icons.person,
                [
                  _buildDetailRow("Patient:", caseData.patientName),
                  _buildDetailRow("Uploaded:", caseData.date.toLocal().toString().split(' ')[0]),
                  _buildDetailRow("Status:", caseData.status, isStatus: true),
                ],
              ),

              const SizedBox(height: 20),

              // Analysis Results Section
              _buildSection(
                "AI Analysis Results",
                Icons.psychology,
                [
                  _buildDetailRow("Media Type:", caseData.mediaType.toUpperCase()),
                  _buildDetailRow("AI Result:", caseData.aiResult ?? 'Analysis pending...'),
                ],
              ),

              // Symptoms Section
              if (caseData.symptoms != null && caseData.symptoms!.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildSection(
                  "Reported Symptoms",
                  Icons.sick,
                  caseData.symptoms!.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 6, color: warningColor),
                          const SizedBox(width: 8),
                          Text(
                            "${entry.key}: ${entry.value}",
                            style: _textStyle(),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ],

              const SizedBox(height: 20),

              // Media Section
              _buildMediaSection(),

              const SizedBox(height: 20),

              // Doctor Notes Section
              _buildSection(
                "Doctor Notes",
                Icons.note_alt,
                [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(defaultPadding),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: secondaryColor.withOpacity(0.1)),
                    ),
                    child: Text(
                      caseData.doctorNotes?.isNotEmpty == true 
                          ? caseData.doctorNotes! 
                          : 'No notes added yet',
                      style: _textStyle().copyWith(
                        fontStyle: caseData.doctorNotes?.isNotEmpty == true 
                            ? FontStyle.normal 
                            : FontStyle.italic,
                        color: caseData.doctorNotes?.isNotEmpty == true 
                            ? secondaryColor.withOpacity(0.8) 
                            : secondaryColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Close",
                    style: TextStyle(fontSize: bodySize, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: secondaryColor,
                fontSize: bodySize,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: secondaryColor.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: secondaryColor.withOpacity(0.7),
                fontSize: captionSize,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isStatus ? _buildStatusBadge(value) : Text(
              value,
              style: _textStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'tb':
        statusColor = errorColor;
        break;
      case 'not tb':
        statusColor = successColor;
        break;
      case 'needs lab test':
        statusColor = warningColor;
        break;
      default:
        statusColor = accentColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: statusColor,
          fontSize: captionSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    if (caseData.mediaType == 'xray') {
      return _buildSection(
        "X-ray Image",
        Icons.medical_services,
        [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              caseData.mediaUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                decoration: BoxDecoration(
                  color: secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        color: secondaryColor.withOpacity(0.5),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Failed to load image",
                        style: TextStyle(
                          color: secondaryColor.withOpacity(0.5),
                          fontSize: captionSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (caseData.mediaType == 'cough') {
      return _buildSection(
        "Audio Analysis",
        Icons.audiotrack,
        [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.audiotrack, color: accentColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Cough audio file available",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: bodySize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.play_circle_fill,
                    color: accentColor,
                    size: 32,
                  ),
                  onPressed: () {
                    // Play audio logic remains here
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  TextStyle _titleStyle() => TextStyle(
    fontWeight: FontWeight.w600,
    color: secondaryColor,
    fontSize: bodySize,
  );
  
  TextStyle _textStyle() => TextStyle(
    color: secondaryColor.withOpacity(0.8),
    fontSize: captionSize,
  );
}