import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils/snackbar_helper.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  String _fullName = '';
  String _email = '';
  String _birthday = '';
  String _sex = '';

  @override
  void initState() {
    super.initState();
    _loadClientProfile();
  }

  Future<void> _loadClientProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      final firstName = data['first_name'] ?? '';
      final middleName = data['middle_name'] ?? '';
      final lastName = data['last_name'] ?? '';
      _fullName = [firstName, middleName, lastName].where((p) => p.isNotEmpty).join(' ');

      _email = data['email'] ?? '';
      _birthday = data['birthday']?.split('T').first ?? '';
      _sex = data['sex'] ?? '';
      setState(() {});
    }
  }

  Widget _buildLabel(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Full Name", _fullName),
                _buildLabel("Email", _email),
                _buildLabel("Birthday", _birthday),
                _buildLabel("Sex", _sex),
                const Spacer(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showCustomSnackBar(context, "✅ Profile loaded successfully");
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text("OK"),
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
