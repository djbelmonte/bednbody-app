import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'client_home.dart';
import 'therapist_home.dart';
import 'therapist_details_screen.dart';
import 'client_details_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'client';
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        // LOGIN
        UserCredential userCred = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final uid = userCred.user!.uid;
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        final role = doc['role'];

        if (role == 'client') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TherapistHomeScreen()),
          );
        }
      } else {
        // SIGNUP
        UserCredential userCred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCred.user!.uid)
            .set({
          'email': _emailController.text.trim(),
          'role': _selectedRole,
        });

        if (_selectedRole == 'client') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ClientDetailsScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TherapistDetailsScreen()),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Auth failed: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF1C3A32), // Bednbody dark green
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 250,
                ),
                Text(
                  _isLogin ? "Welcome Back" : "Create an Account",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.email, color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.black),
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.lock, color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                if (!_isLogin) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    iconEnabledColor: Colors.black,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: "Select Role",
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.person, color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedRole = val);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                          value: "client", child: Text("Client")),
                      DropdownMenuItem(
                          value: "therapist", child: Text("Therapist")),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700), // gold
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: Text(_isLogin ? "Login" : "Sign Up"),
                      ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() => _isLogin = !_isLogin);
                  },
                  child: Text(
                    _isLogin
                        ? "Don't have an account? Sign Up"
                        : "Already have an account? Login",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
