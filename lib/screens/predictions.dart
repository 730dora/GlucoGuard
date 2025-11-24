import 'package:flutter/material.dart';
import '../services/api.dart';
import 'result.dart';
import '../theme.dart';

class PredictionScreen extends StatefulWidget {
  final String uid; // Added UID
  final String email;
  final String gender;
  final String username;

  const PredictionScreen({
    super.key,
    required this.uid,
    required this.email,
    required this.gender,
    required this.username
  });

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for the input fields
  final Map<String, TextEditingController> data = {
    'glucose': TextEditingController(),
    'weight': TextEditingController(),
    'height': TextEditingController(),
    'age': TextEditingController(),
    'systolic': TextEditingController(),
    'diastolic': TextEditingController(),
    'insulin': TextEditingController(),
    'skinThickness': TextEditingController(),
  };

  void _predict() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final double weightKg = double.parse(data['weight']!.text);
      final double heightCm = double.parse(data['height']!.text);

      if (heightCm == 0) throw Exception("Height cannot be zero");

      final double heightM = heightCm / 100;
      final double calculatedBmi = weightKg / (heightM * heightM);

      // Prepare input for the API/Formula
      final Map<String, double> inputForApi = {
        'glucose': double.parse(data['glucose']!.text),
        'age': double.parse(data['age']!.text),
        'systolic': double.parse(data['systolic']!.text),
        'diastolic': double.parse(data['diastolic']!.text),
        'insulin': double.parse(data['insulin']!.text),
        'skinThickness': double.parse(data['skinThickness']!.text),
        'bmi': calculatedBmi,
        'gender': (widget.gender == "Male") ? 1.0 : 0.0,
      };

      // call the new api service (Passing UID)
      final result = await ApiService.predict(inputForApi, widget.uid);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            // We pass "User" or fetch it again, but usually result screen just needs the data
            builder: (_) => ResultScreen(
                result: result,
                username: widget.username, // Username
                uid: widget.uid,           // UID for profile
                email: widget.email        // Email for profile
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    for (var controller in data.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Prediction',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Enter your medical data to run the AI model.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // --- THIS LOOP GENERATES THE TEXT FIELDS ---
            ...data.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextFormField(
                controller: e.value,
                decoration: InputDecoration(
                  labelText: _getLabelText(e.key),
                  hintText: _getHintText(e.key),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                v == null || double.tryParse(v) == null
                    ? 'Enter valid number'
                    : null,
              ),
            )),
            // -------------------------------------------

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _predict,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Predict'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _formKey.currentState?.reset();
                for (var c in data.values) {
                  c.clear();
                }
              },
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: Colors.grey[700]),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for Labels
  String _getLabelText(String key) {
    switch (key) {
      case 'glucose': return 'Glucose Level';
      case 'weight': return 'Weight (in kg)';
      case 'height': return 'Height (in cm)';
      case 'systolic': return 'Systolic BP (top number)';
      case 'diastolic': return 'Diastolic BP (bottom number)';
      case 'insulin': return 'Insulin Level';
      case 'skinThickness': return 'Skin Thickness';
      case 'age': return 'Age';
      default: return key;
    }
  }

  // Helper for Hints
  String _getHintText(String key) {
    switch (key) {
      case 'glucose': return 'e.g., 100';
      case 'weight': return 'e.g., 70';
      case 'height': return 'e.g., 175';
      case 'age': return 'e.g., 45';
      case 'systolic': return 'e.g., 120';
      case 'diastolic': return 'e.g., 80';
      case 'insulin': return 'e.g., 10';
      case 'skinThickness': return 'e.g., 25';
      default: return '';
    }
  }
}