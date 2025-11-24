import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

class HistoryDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const HistoryDetailsScreen({super.key, required this.data});

  // Helper to get color
  Color _getRiskColor(double prob) {
    if (prob > 0.7) return Colors.redAccent;
    if (prob > 0.4) return AppTheme.violet;
    return AppTheme.mint;
  }

  String _formatDateTime(String isoString) {
    try {
      final DateTime date = DateTime.parse(isoString);
      // Format: "Nov 24, 2025 at 2:30 PM"
      return DateFormat('MMM d, yyyy • h:mm a').format(date);
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final input = data['input'] as Map<String, dynamic>? ?? {};
    final double probability = data['probability']?.toDouble() ?? 0.0;
    final String risk = data['risk'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction Details"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. DATE HEADER
            Center(
              child: Text(
                _formatDateTime(data['date']),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),

            // 2. RESULT CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getRiskColor(probability).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getRiskColor(probability).withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Text(
                    risk,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _getRiskColor(probability),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Confidence: ${(probability * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Source: ${data['source'] ?? 'Unknown'}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 3. THE "ALL DETAILS" SECTION
            const Text(
              "Inputs Record",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Generate a row for every input saved
            ..._buildInputRows(input),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildInputRows(Map<String, dynamic> input) {
    // Map standard keys to readable labels
    final labels = {
      'glucose': 'Glucose Level',
      'bmi': 'BMI',
      'age': 'Age',
      'systolic': 'Blood Pressure (Systolic)',
      'diastolic': 'Blood Pressure (Diastolic)',
      'insulin': 'Insulin',
      'skinThickness': 'Skin Thickness',
      'gender': 'Gender Value',
    };

    return input.entries.map((entry) {
      final key = entry.key;
      final value = entry.value;

      // Skip internal technical fields if any
      if (key == 'source') return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labels[key] ?? key, // Use readable label or fallback to key
              style: const TextStyle(color: Colors.black87),
            ),
            Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList();
  }
}