import 'dart:convert';
import 'dart:math'; // For local fallback math
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiService {

  // IP ADDRESS:
  // '10.0.2.2:5000' for Android Emulator.
  // 'mypcIP:5000' (e.g., 192.168.1.5:5000) for a real phone.
  static const String _baseUrl = 'http://10.0.2.2:5000';

  /// 1. PREDICT: Tries Python first, falls back to Local if offline
  static Future<Map<String, dynamic>> predict(Map<String, double> input, String uid) async {
    Map<String, dynamic> result;

    try {
      // OPTION A: ONLINE (Python Backend)
      // We try to talk to the Python script
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(input),
      ).timeout(const Duration(seconds: 3)); // Timeout fast if offline [cite: 16]

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        result = {
          'risk': data['risk'],
          'probability': (data['probability'] as num).toDouble(),
          'input': input,
          'date': DateTime.now().toIso8601String(),
          'source': 'Online (AI Model)'
        };
      } else {
        throw Exception('Server error');
      }

    } catch (e) {
      // --- OPTION B: OFFLINE (Local Fallback)  ---
      print("Offline mode triggered: $e");
      result = _calculateLocal(input);
      result['source'] = 'Offline (Local)';
    }

    // 2. SAVE TO FIREBASE [cite: 90]
    // We save the result to the Cloud Firestore database
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
    double riskScore = 0.0;
    riskScore += (input['glucose']! * 0.005);
    riskScore += (input['bmi']! * 0.01);
    riskScore += (input['age']! * 0.005);
    if (input['gender'] == 1.0) riskScore += 0.05; // Male adjustment

    // randomness for realness
    riskScore += Random().nextDouble() * 0.05;

    if (riskScore > 0.99) riskScore = 0.99;
    if (riskScore < 0.01) riskScore = 0.01;

    String risk;
    if (riskScore > 0.7) risk = "High Risk (Diabetic)";
    else if (riskScore > 0.4) risk = "Medium Risk (Pre-Diabetic)";
    else risk = "Low Risk (Non-Diabetic)";

    return {
      'risk': risk,
      'probability': riskScore,
      'input': input,
      'date': DateTime.now().toIso8601String(),
    };
  }
}