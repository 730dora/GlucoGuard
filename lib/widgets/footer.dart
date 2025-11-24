import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/home.dart';
import '../screens/predictions.dart';
import '../screens/history.dart';
import '../screens/profile.dart';
import 'header.dart';

class Footer extends StatefulWidget {
  final String uid;
  final String email;

  const Footer({super.key, required this.uid, required this.email});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  int _index = 0;
  String _username = "Loading...";
  String _gender = "Male"; // Default fallback

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _username = data['username'] ?? "User";
          _gender = data['gender'] ?? "Male";
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pass the UID and fetched data to the screens
    final List<Widget> pages = [
      HomeScreen(uid: widget.uid, username: _username), // Note: HomeScreen needs update next!
      PredictionScreen(uid: widget.uid, email: widget.email, gender: _gender, username: _username), // PredictionScreen needs update next!
      HistoryScreen(uid: widget.uid), // HistoryScreen needs update next!
      ProfileScreen(uid: widget.uid, username: _username, email: widget.email), // ProfileScreen needs update next!
    ];

    return Scaffold(
      appBar: HeaderBar(
        username: _username,
        onProfileTap: () => setState(() => _index = 3),
      ),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: "Predict"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}