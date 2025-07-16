import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConsultationBookingScreen extends StatefulWidget {
  final String lawyerId;
  final String lawyerName;

  const ConsultationBookingScreen({
    super.key,
    required this.lawyerId,
    required this.lawyerName,
  });

  @override
  State<ConsultationBookingScreen> createState() =>
      _ConsultationBookingScreenState();
}

class _ConsultationBookingScreenState extends State<ConsultationBookingScreen> {
  DateTime? _selectedDateTime;
  final TextEditingController _notesController = TextEditingController();

  Future<void> _submitConsultation() async {
    final clientId = FirebaseAuth.instance.currentUser?.uid;
    if (clientId == null || _selectedDateTime == null) return;

    await FirebaseFirestore.instance.collection('consultations').add({
      'client': clientId,
      'lawyer': widget.lawyerId,
      'consultation_time': _selectedDateTime,
      'notes': _notesController.text.trim(),
      'created_at': FieldValue.serverTimestamp(),  
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Consultation booked successfully!")),
      );
      Navigator.pop(context);
    }
  }

  void _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book a Consultation")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You are booking a consultation with Atty ${widget.lawyerName}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text(
                _selectedDateTime == null
                    ? "Select consultation date & time"
                    : "Consultation: ${_selectedDateTime!.toLocal()}".split('.')[0],
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLength: 250,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Notes (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedDateTime == null ? null : _submitConsultation,
                child: const Text("Confirm Booking"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
