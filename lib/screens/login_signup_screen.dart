import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'client_home.dart';
import 'lawyer_home.dart';

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

  Future<void> _submit() async {
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
        print("✅ Logged in as $role");

        if (role == 'client') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LawyerHomeScreen()),
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

        print("✅ Signed up as $_selectedRole");

        // Redirect after signup
        if (_selectedRole == 'client') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LawyerHomeScreen()),
          );
        }
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Auth failed.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? "Login" : "Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            if (!_isLogin) ...[
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: _selectedRole,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedRole = val);
                  }
                },
                items: const [
                  DropdownMenuItem(value: "client", child: Text("Client")),
                  DropdownMenuItem(value: "lawyer", child: Text("Lawyer")),
                ],
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isLogin ? "Login" : "Sign Up"),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() => _isLogin = !_isLogin);
              },
              child: Text(_isLogin
                  ? "Don't have an account? Sign Up"
                  : "Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
