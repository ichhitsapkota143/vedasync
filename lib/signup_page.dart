import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'landing_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _batchController = TextEditingController();

  String? _selectedProgram;
  String? _selectedRole;
  bool _isSubmitting = false;

  final List<String> _programs = [
    'Computer Engineering',
    'Information Technology',
    'Electronics & Communication',
    'Civil Engineering',
    'Business Administration',
    'Architecture',
  ];

  final List<String> _roles = ['Student', 'Teacher'];

  void _showMessage(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color ?? Colors.black87),
    );
  }

  Future<void> _submitRegistration() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();
    final name = _nameController.text.trim();
    final batch = _batchController.text.trim();
    final program = _selectedProgram;
    final role = _selectedRole;

    if (email.isEmpty || !email.endsWith('@cosmoscollege.edu.np')) {
      _showMessage('Only @cosmoscollege.edu.np emails allowed', color: Colors.red);
      return;
    }

    if (username.isEmpty || password.isEmpty || name.isEmpty || batch.isEmpty || program == null || role == null) {
      _showMessage('Please fill all fields', color: Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);
    _showMessage('Registration successful! Redirecting...', color: Colors.green);

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection('usernames').doc(username).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'batch': batch,
        'program': program,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Small delay for user to see the message
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LandingPage(),
            transitionsBuilder: (_, animation, __, child) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.ease)).animate(animation);

              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Registration failed', color: Colors.red);
    } catch (e) {
      _showMessage('Error: $e', color: Colors.red);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(
              controller: _emailController,
              label: 'Email (@cosmoscollege.edu.np)',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _buildInputField(controller: _nameController, label: 'Full Name'),
            const SizedBox(height: 16),
            _buildInputField(controller: _usernameController, label: 'Username'),
            const SizedBox(height: 16),
            _buildInputField(controller: _batchController, label: 'Batch'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedProgram,
              items: _programs.map((program) {
                return DropdownMenuItem(value: program, child: Text(program));
              }).toList(),
              onChanged: (value) => setState(() => _selectedProgram = value),
              decoration: const InputDecoration(
                labelText: 'Program',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: _roles.map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (value) => setState(() => _selectedRole = value),
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitRegistration,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
