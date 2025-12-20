/// Utility class for input sanitization and validation
class InputSanitizer {
  // Username constraints
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  
  // Email constraints
  static const int maxEmailLength = 254; // RFC 5321
  
  // Password constraints
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  
  // Firebase UID length
  static const int firebaseUidLength = 28;

  /// Sanitizes and validates username
  /// Returns null if invalid, otherwise returns sanitized username
  static String? sanitizeUsername(String username) {
    if (username.isEmpty) return null;
    
    // Trim whitespace
    final trimmed = username.trim();
    
    // Check length
    if (trimmed.length < minUsernameLength || trimmed.length > maxUsernameLength) {
      return null;
    }
    
    // Allow only alphanumeric, spaces, hyphens, underscores
    final validPattern = RegExp(r'^[a-zA-Z0-9 _-]+$');
    if (!validPattern.hasMatch(trimmed)) {
      return null;
    }
    
    // Prevent only whitespace
    if (trimmed.trim().isEmpty) {
      return null;
    }
    
    return trimmed;
  }

  /// Validates email format using proper regex
  /// Returns true if email is valid
  static bool validateEmail(String email) {
    if (email.isEmpty) return false;
    
    final trimmed = email.trim().toLowerCase();
    
    // Check length
    if (trimmed.length > maxEmailLength) return false;
    
    // RFC 5322 compliant email regex (simplified but practical)
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    return emailPattern.hasMatch(trimmed);
  }

  /// Sanitizes email (trim and lowercase)
  /// Returns null if invalid, otherwise returns sanitized email
  static String? sanitizeEmail(String email) {
    if (!validateEmail(email)) return null;
    return email.trim().toLowerCase();
  }

  /// Validates password
  /// Returns true if password meets requirements
  static bool validatePassword(String password) {
    if (password.length < minPasswordLength || password.length > maxPasswordLength) {
      return false;
    }
    return true;
  }

  /// Sanitizes numeric input with range validation
  /// Returns null if invalid, otherwise returns parsed double
  static double? sanitizeNumericInput(
    String input, {
    double? min,
    double? max,
  }) {
    if (input.isEmpty) return null;
    
    // Trim whitespace
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    
    // Prevent extremely long inputs (DoS protection)
    if (trimmed.length > 50) return null;
    
    // Parse to double
    final value = double.tryParse(trimmed);
    if (value == null) return null;
    
    // Check for NaN and Infinity
    if (value.isNaN || value.isInfinite) return null;
    
    // Range validation
    if (min != null && value < min) return null;
    if (max != null && value > max) return null;
    
    return value;
  }

  /// Validates Firebase UID format
  /// Firebase UIDs are exactly 28 characters alphanumeric
  static bool isValidFirebaseUid(String uid) {
    if (uid.isEmpty || uid.length != firebaseUidLength) return false;
    
    // Firebase UIDs are alphanumeric
    final uidPattern = RegExp(r'^[a-zA-Z0-9]+$');
    return uidPattern.hasMatch(uid);
  }

  /// Sanitizes text for safe display (escapes HTML-like characters)
  /// Note: Flutter Text widget handles this automatically, but this is extra safety
  static String sanitizeForDisplay(String text) {
    // Flutter's Text widget automatically escapes, but we can add extra validation
    // Remove null bytes and control characters
    return text.replaceAll(RegExp(r'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]'), '');
  }

  /// Validates numeric range matches backend schema
  static bool validateNumericRange(String fieldName, double value) {
    final schema = <String, List<double>>{
      'glucose': [0.0, 1000.0],
      'diastolic': [0.0, 300.0],
      'skinThickness': [0.0, 100.0],
      'insulin': [0.0, 2000.0],
      'bmi': [0.0, 200.0],
      'age': [0.0, 130.0],
      'gender': [0.0, 1.0],
    };
    
    if (!schema.containsKey(fieldName)) return false;
    
    final range = schema[fieldName]!;
    final min = range[0];
    final max = range[1];
    return value >= min && value <= max;
  }

  /// Validates that a number is finite (not NaN or Infinity)
  static bool isFiniteNumber(double value) {
    return !value.isNaN && !value.isInfinite;
  }
}

