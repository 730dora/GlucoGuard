import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../theme.dart';
import '../widgets/prediction_wheel.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final String username;
  final String uid;
  final String email;
  const ResultScreen({
    super.key,
    required this.result,
    required this.username,
    required this.email,
    required this.uid,
  });

  // Helper risk color for the text
  Color _getRiskColor(double prob) {
    if (prob > 0.7) return Colors.redAccent;
    if (prob > 0.4) return AppTheme.violet;
    return AppTheme.mint;
  }

  @override
  Widget build(BuildContext context) {
    // data from the result map
    final double probability = result['probability'];
    final String risk = result['risk']; // like "High Risk (Diabetic)"

    return Scaffold(
      appBar: HeaderBar(username: username),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Text(
              'Prediction Result',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 30),

          // wheel is now only given the probability
          Center(child: PredictionWheel(probability: probability)),

          const SizedBox(height: 30),

          Center(
            child: Column(
              children: [
                // Risk Text
                Text(
                  risk,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _getRiskColor(probability),
                  ),
                ),
                const SizedBox(height: 8),
                // Chances label
                Text(
                  'Chances of diabetes: ${(probability * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const Text(
            'Health Tips',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...[
            'Drink water instead of soda or sugary drinks.',
            'Try to get 30 minutes of moderate exercise daily.',
            'Eat more vegetables, fruits, and lean protein.',
            'Monitor your glucose levels regularly as advised.',
            'Aim for 7-8 hours of quality sleep per night.',
          ].map(
            (tip) => ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
                color: AppTheme.mint,
              ),
              title: Text(tip),
            ),
          ),
        ],
      ),
    );
  }
}
