import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'client_home.dart';
import 'utils/confirmation_dialog.dart';

class ClientDetailsScreen extends StatefulWidget {
  const ClientDetailsScreen({super.key});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedSex;

  Future<void> _submitDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'first_name': _firstNameController.text.trim(),
      'middle_name': _middleNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'birthday': _selectedDate?.toIso8601String(),
      'sex': _selectedSex,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tell us more about yourself")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInput("First Name", _firstNameController),
            _buildInput("Middle Name", _middleNameController),
            _buildInput("Last Name", _lastNameController),
            const SizedBox(height: 12),
            _buildBirthdayField(),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSex,
              decoration: const InputDecoration(
                labelText: "Sex",
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],
              onChanged: (val) => setState(() => _selectedSex = val),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final confirmed = await showConfirmationDialog(context);
                  if (confirmed) {
                    _submitDetails();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildBirthdayField() {
    final display = _selectedDate == null
        ? "Select Birthday"
        : "Birthday: ${_selectedDate!.toLocal()}".split(' ')[0];

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(1990),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: "Birthday",
          isDense: true,
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(display, style: const TextStyle(fontSize: 14)),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }
}
