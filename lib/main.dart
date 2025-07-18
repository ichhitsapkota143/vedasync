// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'landing_page.dart';
import 'signup_page.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const VedaSyncApp());
}

class VedaSyncApp extends StatelessWidget {
  const VedaSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VedaSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF3F8FE),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/signup': (context) => const SignUpPage(),
        '/dashboard_student': (context) => const StudentDashboard(),
        '/dashboard_teacher': (context) => const TeacherDashboard(),
      },
    );
  }
}
