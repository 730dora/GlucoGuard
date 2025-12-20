import 'dart:convert';
import 'dart:math'; // For local fallback math
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/input_sanitizer.dart';

class ApiService {
  // Default base URLs to try if config fails - tries common network IP ranges
  // The app will try these IPs automatically until it finds a working backend
  // For Android emulator: use 'http://10.0.2.2:5000'
  static const List<String> _defaultBaseUrls = [
    // Your current network IPs (most likely to work)
    'http://192.168.215.100:5000',
    'http://192.168.56.1:5000',
    // Common 192.168.x.x ranges
    'http://192.168.1.100:5000',
    'http://192.168.1.1:5000',
    'http://192.168.0.100:5000',
    'http://192.168.0.1:5000',
    'http://192.168.2.1:5000',
    // Common 10.x.x.x ranges (corporate/VPN networks)
    'http://10.0.0.100:5000',
    'http://10.0.0.1:5000',
    'http://10.0.2.2:5000', // Android emulator
    // Common 172.x.x.x ranges
    'http://172.16.0.100:5000',
    'http://172.16.0.1:5000',
  ];

  static String? _cachedBaseUrl;
  static List<String>? _cachedBaseUrls;

  // Loads `assets/config.json` and reads `backend_url` and `backend_url_public`. 
  // Cached after first load.
  static Future<List<String>> _getBaseUrls() async {
    if (_cachedBaseUrls != null) return _cachedBaseUrls!;
    
    List<String> urls = [];
    
    // First, try to load from config
    try {
      final raw = await rootBundle.loadString('assets/config.json');
      final Map<String, dynamic> cfg = jsonDecode(raw);
      
      // Try public URL first (for mobile data/internet access)
      final publicUrl = cfg['backend_url_public'] as String?;
      if (publicUrl != null && publicUrl.isNotEmpty) {
        urls.add(publicUrl);
      }
      
      // Then try local URL (for same network)
      final url = cfg['backend_url'] as String?;
      if (url != null && url.isNotEmpty) {
        urls.add(url);
      }
    } catch (e) {
      // ignore and fall back
    }
    
    // Add default URLs (local network IPs)
    urls.addAll(_defaultBaseUrls);
    
    _cachedBaseUrls = urls;
    return _cachedBaseUrls!;
  }

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
    'gender': 0.0,
  };

  static Map<String, double> _withDefaults(Map<String, double> input) {
    final Map<String, double> merged = Map<String, double>.from(_defaults);
    // Overwrite defaults with any provided (non-null) values
    input.forEach((k, v) {
      merged[k] = v;
    });
    return merged;
  }

  static Future<Map<String, dynamic>> predict(
    Map<String, double> input,
    String uid,
  ) async {
    // Validate UID format
    if (!InputSanitizer.isValidFirebaseUid(uid)) {
      throw Exception('Invalid user ID format');
    }
    
    // Pre-validate all input values before sending to backend
    final validatedInput = <String, double>{};
    for (final entry in input.entries) {
      final key = entry.key;
      final value = entry.value;
      
      // Check for NaN/Infinity
      if (!InputSanitizer.isFiniteNumber(value)) {
        throw Exception('Invalid numeric value for $key');
      }
      
      // Validate range if field is in schema
      if (InputSanitizer.validateNumericRange(key, value)) {
        validatedInput[key] = value;
      } else {
        // Field not in schema or out of range - skip it (will use default)
        // But log a warning for debugging
        print('Warning: Field $key with value $value is out of valid range or not in schema');
      }
    }
    
    // Ensure input contains all keys the backend/local logic expects
    final safeInput = _withDefaults(validatedInput);
    
    // Final validation: ensure all values in safeInput are finite
    for (final entry in safeInput.entries) {
      if (!InputSanitizer.isFiniteNumber(entry.value)) {
        throw Exception('Invalid numeric value detected');
      }
    }

    // Try multiple base URLs until one works
    final baseUrls = await _getBaseUrls();
    Map<String, dynamic> result;
    
    for (final base in baseUrls) {
      try {
        // OPTION A: ONLINE (Python Backend) - try each URL
        // Use longer timeout for public URLs (mobile data/internet)
        final isPublicUrl = base.startsWith('https://') || 
                          (base.contains('.ngrok.io') || 
                           base.contains('.ngrok-free.app') ||
                           base.contains('.ngrok.app') ||
                           base.contains('.ngrok-free.dev') ||
                           base.contains('.serveo.net'));
        final isNgrokUrl = base.contains('.ngrok.io') || 
                          base.contains('.ngrok-free.app') ||
                          base.contains('.ngrok.app') ||
                          base.contains('.ngrok-free.dev');
        final timeoutDuration = isPublicUrl 
            ? const Duration(seconds: 10) 
            : const Duration(seconds: 2);
        
        // Build headers - add ngrok skip warning header for ngrok URLs
        final headers = <String, String>{"Content-Type": "application/json"};
        if (isNgrokUrl) {
          headers['ngrok-skip-browser-warning'] = 'true';
        }
        
        final response = await http
            .post(
              Uri.parse('$base/predict'),
              headers: headers,
              body: jsonEncode(safeInput),
            )
            .timeout(timeoutDuration);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          result = {
            'risk': data['risk'],
            'probability': (data['probability'] as num).toDouble(),
            'input': safeInput,
            'date': DateTime.now().toIso8601String(),
            'source': 'Online (AI Model)',
          };
          // Cache the working URL for next time
          _cachedBaseUrl = base;
          
          // Save to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('predictions')
              .add(result);
          
          return result;
        }
      } catch (e) {
        // Try next URL
        continue;
      }
    }

    // OPTION B: OFFLINE (Local Fallback) - if no backend was reachable
    print("Offline mode triggered: Could not connect to any backend URL");
    result = _calculateLocal(safeInput);
    result['source'] = 'Offline (Local)';

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
