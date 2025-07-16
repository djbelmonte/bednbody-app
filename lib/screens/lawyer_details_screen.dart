import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'lawyer_home.dart';
import 'utils/confirmation_dialog.dart';

class LawyerDetailsScreen extends StatefulWidget {
  const LawyerDetailsScreen({super.key});

  @override
  State<LawyerDetailsScreen> createState() => _LawyerDetailsScreenState();
}

class _LawyerDetailsScreenState extends State<LawyerDetailsScreen> {
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _selectedDate;
  String? _yearGraduated;
  List<String> _selectedSpecializations = [];
  List<Map<String, dynamic>> _allSpecializations = [];

  @override
  void initState() {
    super.initState();
    _fetchSpecializations();
  }

  Future<void> _fetchSpecializations() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('law_specializations')
        .get();

    setState(() {
      _allSpecializations = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'description': doc['description']
              })
          .toList();
    });
  }

  Future<void> _submitDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'first_name': _firstNameController.text.trim(),
      'middle_name': _middleNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'birthday': _selectedDate?.toIso8601String(),
      'address': _addressController.text.trim(),
      'year_graduated': _yearGraduated,
      'specializations': _selectedSpecializations.toSet().toList(),
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LawyerHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(
      DateTime.now().year - 1979,
      (index) => (1980 + index).toString(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Tell us more about yourself")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInput("First Name", _firstNameController),
                _buildInput("Middle Name", _middleNameController),
                _buildInput("Last Name", _lastNameController),
                _buildInput("Address", _addressController),
                const SizedBox(height: 12),
                _buildBirthdayField(),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _yearGraduated,
                  decoration: const InputDecoration(
                    labelText: "Year Graduated",
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: years.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _yearGraduated = val),
                ),
                const SizedBox(height: 16),
                const Text("Specializations", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_allSpecializations.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _allSpecializations.map((spec) {
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
