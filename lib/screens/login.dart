import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/footer.dart';
import '../theme.dart';
import '../utils/input_sanitizer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedGender;
  bool _isLoginMode = true;
  bool _isLoading = false;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isLoginMode) {
        await _login();
      } else {
        await _register();
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Authentication failed');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    // Sanitize and validate email
    final sanitizedEmail = InputSanitizer.sanitizeEmail(_emailController.text);
    if (sanitizedEmail == null) {
      _showError('Please enter a valid email address');
      return;
    }

    final password = _passwordController.text;
    if (!InputSanitizer.validatePassword(password)) {
      _showError('Invalid password format');
      return;
    }

    // Log in with Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: sanitizedEmail,
      password: password,
    );

    // Validate Firebase UID
    final uid = userCredential.user!.uid;
    if (!InputSanitizer.isValidFirebaseUid(uid)) {
      _showError('Invalid user ID format');
      return;
    }

    // Navigate to Home
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => Footer(uid: uid, email: sanitizedEmail),
      ),
    );
  }

  Future<void> _register() async {
    // Sanitize and validate inputs
    final sanitizedEmail = InputSanitizer.sanitizeEmail(_emailController.text);
    if (sanitizedEmail == null) {
      _showError('Please enter a valid email address');
      return;
    }

    final password = _passwordController.text;
    if (!InputSanitizer.validatePassword(password)) {
      _showError('Password must be between 6 and 128 characters');
      return;
    }

    final sanitizedUsername = InputSanitizer.sanitizeUsername(_usernameController.text);
    if (sanitizedUsername == null) {
      _showError('Username must be 3-30 characters and contain only letters, numbers, spaces, hyphens, or underscores');
      return;
    }

    // Create User in Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: sanitizedEmail,
      password: password,
    );

    // Validate Firebase UID
    final uid = userCredential.user!.uid;
    if (!InputSanitizer.isValidFirebaseUid(uid)) {
      _showError('Invalid user ID format');
      return;
    }

    // Save "Extra" info (Gender, Username) to Firestore Database
    // Sanitize username before storing
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'username': InputSanitizer.sanitizeForDisplay(sanitizedUsername),
      'email': sanitizedEmail,
      'gender': _selectedGender,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Navigate
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => Footer(uid: uid, email: sanitizedEmail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_moon, size: 80, color: AppTheme.mint),
              const SizedBox(height: 10),
              Text('GlucoGuard', style: TextStyle(color: AppTheme.accent, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_isLoginMode) ...[
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Username'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final sanitized = InputSanitizer.sanitizeUsername(v);
                          if (sanitized == null) {
                            return 'Username must be 3-30 characters and contain only letters, numbers, spaces, hyphens, or underscores';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(labelText: 'Gender'),
                        items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                        onChanged: (val) => setState(() => _selectedGender = val),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (!InputSanitizer.validateEmail(v)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (!InputSanitizer.validatePassword(v)) {
                          return 'Password must be between 6 and 128 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_isLoginMode ? 'LOGIN' : 'SIGN UP'),
              ),
              TextButton(
                onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                child: Text(_isLoginMode ? "Create Account" : "I have an account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}