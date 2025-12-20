import 'package:flutter/material.dart';
import '../services/api.dart';
import 'result.dart';
import '../theme.dart';
import '../utils/input_sanitizer.dart';

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
    required this.username,
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
      // Safely parse and validate numeric inputs with range checks
      double? weightKg = InputSanitizer.sanitizeNumericInput(
        data['weight']!.text,
        min: 0.0,
        max: 500.0, // Reasonable weight limit
      );
      double? heightCm = InputSanitizer.sanitizeNumericInput(
        data['height']!.text,
        min: 0.0,
        max: 300.0, // Reasonable height limit
      );
      
      double? calculatedBmi;
      if (weightKg != null && heightCm != null && heightCm > 0) {
        // Validate inputs before calculation
        if (!InputSanitizer.isFiniteNumber(weightKg) || 
            !InputSanitizer.isFiniteNumber(heightCm)) {
          throw Exception('Invalid numeric values');
        }
        final double heightM = heightCm / 100;
        calculatedBmi = weightKg / (heightM * heightM);
        // Validate BMI result
        if (!InputSanitizer.isFiniteNumber(calculatedBmi) || 
            !InputSanitizer.validateNumericRange('bmi', calculatedBmi)) {
          calculatedBmi = null;
        }
      }

      // Helper to sanitize and validate each field
      double? tryField(String key, {double? min, double? max}) {
        final text = data[key]!.text;
        if (text.isEmpty) return null;
        
        // Use sanitizer with range validation
        final value = InputSanitizer.sanitizeNumericInput(text, min: min, max: max);
        if (value == null) return null;
        
        // Check for NaN/Infinity
        if (!InputSanitizer.isFiniteNumber(value)) return null;
        
        // Validate against backend schema ranges
        if (!InputSanitizer.validateNumericRange(key, value)) return null;
        
        return value;
      }

      final Map<String, double> inputForApi = {};
      
      // Validate each field with appropriate ranges
      final glucose = tryField('glucose', min: 0.0, max: 1000.0);
      if (glucose != null) inputForApi['glucose'] = glucose;

      final age = tryField('age', min: 0.0, max: 130.0);
      if (age != null) inputForApi['age'] = age;

      // Systolic is not in backend schema, but we'll validate it anyway
      final systolic = tryField('systolic', min: 0.0, max: 300.0);
      if (systolic != null && InputSanitizer.isFiniteNumber(systolic)) {
        // Systolic is not sent to backend, but we validate it for data integrity
      }

      final diastolic = tryField('diastolic', min: 0.0, max: 300.0);
      if (diastolic != null) inputForApi['diastolic'] = diastolic;

      final insulin = tryField('insulin', min: 0.0, max: 2000.0);
      if (insulin != null) inputForApi['insulin'] = insulin;

      final skin = tryField('skinThickness', min: 0.0, max: 100.0);
      if (skin != null) inputForApi['skinThickness'] = skin;

      if (calculatedBmi != null && InputSanitizer.isFiniteNumber(calculatedBmi)) {
        inputForApi['bmi'] = calculatedBmi;
      }

      inputForApi['gender'] = (widget.gender == "Male") ? 1.0 : 0.0;

      // Validate UID before API call
      if (!InputSanitizer.isValidFirebaseUid(widget.uid)) {
        throw Exception('Invalid user ID');
      }

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
              uid: widget.uid, // UID for profile
              email: widget.email, // Email for profile
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
            ...data.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: e.value,
                  decoration: InputDecoration(
                    labelText: _getLabelText(e.key),
                    hintText: _getHintText(e.key),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    // Allow empty fields (user may leave optional fields blank).
                    if (v == null || v.trim().isEmpty) return null;
                    
                    // Get range constraints based on field type
                    double? min, max;
                    switch (e.key) {
                      case 'glucose':
                        min = 0.0;
                        max = 1000.0;
                        break;
                      case 'diastolic':
                        min = 0.0;
                        max = 300.0;
                        break;
                      case 'skinThickness':
                        min = 0.0;
                        max = 100.0;
                        break;
                      case 'insulin':
                        min = 0.0;
                        max = 2000.0;
                        break;
                      case 'age':
                        min = 0.0;
                        max = 130.0;
                        break;
                      case 'weight':
                        min = 0.0;
                        max = 500.0;
                        break;
                      case 'height':
                        min = 0.0;
                        max = 300.0;
                        break;
                      case 'systolic':
                        min = 0.0;
                        max = 300.0;
                        break;
                    }
                    
                    // Use sanitizer for validation
                    final value = InputSanitizer.sanitizeNumericInput(v, min: min, max: max);
                    if (value == null) {
                      if (min != null && max != null) {
                        return 'Enter a valid number between $min and $max';
                      }
                      return 'Enter a valid number';
                    }
                    
                    // Check for NaN/Infinity
                    if (!InputSanitizer.isFiniteNumber(value)) {
                      return 'Invalid number value';
                    }
                    
                    return null;
                  },
                ),
              ),
            ),

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
                foregroundColor: Colors.grey[700],
              ),
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
      case 'glucose':
        return 'Glucose Level';
      case 'weight':
        return 'Weight (in kg)';
      case 'height':
        return 'Height (in cm)';
      case 'systolic':
        return 'Systolic BP (top number)';
      case 'diastolic':
        return 'Diastolic BP (bottom number)';
      case 'insulin':
        return 'Insulin Level';
      case 'skinThickness':
        return 'Skin Thickness';
      case 'age':
        return 'Age';
      default:
        return key;
    }
  }

  // Helper for Hints
  String _getHintText(String key) {
    switch (key) {
      case 'glucose':
        return 'e.g., 100';
      case 'weight':
        return 'e.g., 70';
      case 'height':
        return 'e.g., 175';
      case 'age':
        return 'e.g., 45';
      case 'systolic':
        return 'e.g., 120';
      case 'diastolic':
        return 'e.g., 80';
      case 'insulin':
        return 'e.g., 10';
      case 'skinThickness':
        return 'e.g., 25';
      default:
        return '';
    }
  }
}
