import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import this
import '../screens/login.dart';

class ProfileScreen extends StatelessWidget {
  final String uid;
  final String username;
  final String email;

  const ProfileScreen({super.key, required this.uid, required this.username, required this.email});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Real Firebase Logout
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (r) => false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 80),
          Text(username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(email),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _logout(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text("Logout"),
          )
        ],
      ),
    );
  }
}