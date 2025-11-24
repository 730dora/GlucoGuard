import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login.dart';
import 'widgets/footer.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // connects to the Firebase project
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GlucoGuardApp());
}

class GlucoGuardApp extends StatelessWidget {
  const GlucoGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlucoGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Checks if user is already logged in
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            // User is logged in! Send them to the Footer (Dashboard)
            // pass the UID so we can fetch their profile data later
            return Footer(uid: snapshot.data!.uid, email: snapshot.data!.email!);
          }
          return const LoginScreen();
        },
      ),
    );
  }
}