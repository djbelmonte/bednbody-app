import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class TherapistDashboardScreen extends StatefulWidget {
  const TherapistDashboardScreen({super.key});

  @override
  State<TherapistDashboardScreen> createState() => _TherapistDashboardScreenState();
}

class _TherapistDashboardScreenState extends State<TherapistDashboardScreen> {
  Map<String, dynamic>? _consultation;
  Duration _timeRemaining = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadUpcomingConsultation();
  }

  Future<void> _loadUpcomingConsultation() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final query = await FirebaseFirestore.instance
        .collection('consultations')
        .where('therapist', isEqualTo: uid)
        .where('consultation_time', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('consultation_time')
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      final Timestamp? timestamp = data['consultation_time'];
      if (timestamp == null) return;

      final consultationTime = timestamp.toDate();
      _startCountdown(consultationTime);

      setState(() {
        _consultation = data;
      });
    }
  }

  void _startCountdown(DateTime consultationTime) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final diff = consultationTime.difference(now);
      if (diff.isNegative) {
        _timer?.cancel();
        setState(() => _timeRemaining = Duration.zero);
      } else {
        setState(() => _timeRemaining = diff);
      }
    });
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds <= 0) return "Started";
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return "$hours h $minutes m $seconds s";
  }

  Widget _buildConsultationReminderCard() {
    if (_consultation == null) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "No one has booked a consultation with you yet.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    // Fetch the client document using FutureBuilder
    final clientId  = _consultation!['client'] as String;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(clientId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final clientData = snapshot.data!.data() as Map<String, dynamic>;
        final clientName = [
          clientData['first_name'],
          clientData['middle_name'],
          clientData['last_name'],
        ].where((part) => part != null && part.toString().trim().isNotEmpty).join(' ');

        final notes = _consultation!['notes'] ?? '';
        final consultationTime = (_consultation!['consultation_time'] as Timestamp).toDate();
        final formattedTime = DateFormat.yMMMMd().add_jm().format(consultationTime);

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Upcoming Consultation", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("With $clientName"),
                Text("Scheduled on $formattedTime"),
                Text("Time remaining: ${_formatDuration(_timeRemaining)}"),
                const SizedBox(height: 8),
                Text(
                  "Notes: $notes",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Therapist Dashboard")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildConsultationReminderCard(),
          // You can add more dashboard widgets here
        ],
      ),
    );
  }
}
