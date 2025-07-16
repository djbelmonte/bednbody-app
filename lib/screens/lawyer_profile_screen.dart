import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'utils/snackbar_helper.dart';

class LawyerProfileScreen extends StatefulWidget {
  const LawyerProfileScreen({super.key});

  @override
  State<LawyerProfileScreen> createState() => _LawyerProfileScreenState();
}

class _LawyerProfileScreenState extends State<LawyerProfileScreen> {
  final TextEditingController _addressController = TextEditingController();
  final List<String> _selectedSpecializations = [];
  final List<Map<String, dynamic>> _availableSpecializations = [];

  String _fullName = '';
  String _email = '';
  String _birthday = '';
  String _yearGraduated = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadSpecializations();
  }

  Future<void> _loadProfile() async {
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
      _birthday = data['birthday'] ?? '';
      _yearGraduated = data['year_graduated'] ?? '';
      _addressController.text = data['address'] ?? '';
      _selectedSpecializations.addAll(List<String>.from(data['specializations'] ?? []));
      setState(() {});
    }
  }

  Future<void> _loadSpecializations() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('law_specializations').get();

    setState(() {
      _availableSpecializations.addAll(snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }));
    });
  }

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'address': _addressController.text.trim(),
      'specializations': _selectedSpecializations.toSet().toList(),
    });

    showCustomSnackBar(context, "✅ Profile updated");
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
                _buildLabel("Birthday", _birthday.split('T').first),
                _buildLabel("Year Graduated", _yearGraduated),

                TextField(
                  controller: _addressController,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: "Address",
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                const Text("Specializations", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_availableSpecializations.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _availableSpecializations.map((spec) {
                      final isSelected = _selectedSpecializations.contains(spec['id']);
                      return FilterChip(
                        label: Text(spec['name'], style: const TextStyle(fontSize: 13)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSpecializations.add(spec['id']);
                            } else {
                              _selectedSpecializations.remove(spec['id']);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                const Spacer(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text("Save"),
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
