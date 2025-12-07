import 'dart:convert';
import 'dart:math'; // For local fallback math
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiService {

  // IP ADDRESS:
  // '10.0.2.2:5000' for Android Emulator.
  // For a real phone on the same Wi‑Fi, set this to your PC's LAN IP, e.g.
  // 'http://192.168.215.100:5000'
  static const String _baseUrl = 'http://192.168.215.100:5000';

  /// 1. PREDICT: Tries Python first, fills missing fields with sensible
  /// defaults so predictions still work with partial data, then falls back
  /// to local calculation if the backend is unreachable.
  static const Map<String, double> _defaults = {
    'glucose': 100.0,
    'diastolic': 70.0,
    'skinThickness': 20.0,
    'insulin': 80.0,
    'bmi': 25.0,
    'age': 30.0,
    'gender': 0.0
  };

  static Map<String, double> _withDefaults(Map<String, double> input) {
    final Map<String, double> merged = Map<String, double>.from(_defaults);
    // Overwrite defaults with any provided (non-null) values
    input.forEach((k, v) {
      if (v != null) merged[k] = v;
    });
    return merged;
  }

  static Future<Map<String, dynamic>> predict(Map<String, double> input, String uid) async {
    Map<String, dynamic> result;

    // Ensure input contains all keys the backend/local logic expects
    final safeInput = _withDefaults(input);

    try {
      // OPTION A: ONLINE (Python Backend)
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(safeInput),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        result = {
          'risk': data['risk'],
          'probability': (data['probability'] as num).toDouble(),
          'input': safeInput,
          'date': DateTime.now().toIso8601String(),
          'source': 'Online (AI Model)'
        };
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }

    } catch (e) {
      // OPTION B: OFFLINE (Local Fallback) using the same safeInput
      print("Offline mode triggered: $e");
      result = _calculateLocal(safeInput);
      result['source'] = 'Offline (Local)';
    }

    // Save to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('predictions')
        .add(result);

    return result;
  }

  /// 2. GET HISTORY: Fetches from Firestore
  static Future<List<Map<String, dynamic>>> getHistory(String uid) async {
    try {
      final qs = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('predictions')
          .orderBy('date', descending: true)
          .get();

      return qs.docs.map((e) => e.data()).toList();
    } catch (e) {
      return [];
    }
  }

  /// Local Formula (Fallback)
  static Map<String, dynamic> _calculateLocal(Map<String, double> input) {
    // input is expected to already contain defaults via _withDefaults
    double glucose = input['glucose'] ?? _defaults['glucose']!;
    double bmi = input['bmi'] ?? _defaults['bmi']!;
    double age = input['age'] ?? _defaults['age']!;
    double gender = input['gender'] ?? _defaults['gender']!;

    double riskScore = 0.0;
    riskScore += (glucose * 0.005);
    riskScore += (bmi * 0.01);
    riskScore += (age * 0.005);
    if (gender == 1.0) riskScore += 0.05; // Male adjustment

    // randomness for realness
    riskScore += Random().nextDouble() * 0.05;

    if (riskScore > 0.99) riskScore = 0.99;
    if (riskScore < 0.01) riskScore = 0.01;

    String risk;
    if (riskScore > 0.7) {
      risk = "High Risk (Diabetic)";
    } else if (riskScore > 0.4) {
      risk = "Medium Risk (Pre-Diabetic)";
    } else {
      risk = "Low Risk (Non-Diabetic)";
    }

    return {
      'risk': risk,
      'probability': riskScore,
      'input': input,
      'date': DateTime.now().toIso8601String(),
    };
  }
}