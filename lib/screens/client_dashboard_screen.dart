import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'lawyer_preview_screen.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _lawyerSuggestions = [];
  List<Map<String, dynamic>> _specializationSuggestions = [];
  bool _isLoading = false;

  Map<String, dynamic>? _consultation;
  Duration _timeRemaining = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadConsultation();
  }

  void _onSearchChanged(String query) async {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      setState(() {
        _lawyerSuggestions = [];
        _specializationSuggestions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    final lawyerSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'lawyer')
        .get();

    final lawyers = lawyerSnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'fullName':
                  "${doc['first_name']} ${doc['middle_name']} ${doc['last_name']}".toLowerCase(),
              'displayName':
                  "${doc['first_name']} ${doc['middle_name']} ${doc['last_name']}"
            })
        .where((lawyer) => lawyer['fullName']!.contains(search))
        .toList();

    lawyers.sort((a, b) => a['displayName']!.compareTo(b['displayName']!));
    final topLawyers = lawyers.take(3).toList();

    final specSnapshot = await FirebaseFirestore.instance
        .collection('law_specializations')
        .get();

    final specs = specSnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'name': doc['name'].toString(),
            })
        .where((spec) => spec['name']!.toLowerCase().contains(search))
        .toList();

    specs.sort((a, b) => a['name']!.compareTo(b['name']!));
    final topSpecs = specs.take(3).toList();

    setState(() {
      _lawyerSuggestions = topLawyers;
      _specializationSuggestions = topSpecs;
      _isLoading = false;
    });
  }


  Future<void> _loadConsultation() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final query = await FirebaseFirestore.instance
        .collection('consultations')
        .where('client', isEqualTo: uid)
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "You don't have any consultations booked yet.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(_consultation!['lawyer']) // assuming this is the UID string
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final lawyerData = snapshot.data!.data() as Map<String, dynamic>;
        final lawyerName = [
          lawyerData['first_name'],
          lawyerData['middle_name'],
          lawyerData['last_name'],
        ].where((part) => part != null && part.toString().trim().isNotEmpty).join(' ');

        final notes = _consultation!['notes'] ?? '';
        final consultationTime = (_consultation!['consultation_time'] as Timestamp).toDate();
        final formattedTime = DateFormat.yMMMMd().add_jm().format(consultationTime);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Upcoming Consultation", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("With Atty. $lawyerName"),
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
    return Column(
      children: [
        // 🔍 Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: "Search by lawyer or specialization...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // 📅 Reminder Card
        _buildConsultationReminderCard(),

        if (_isLoading) const CircularProgressIndicator(),

        if (!_isLoading &&
            _lawyerSuggestions.isEmpty &&
            _specializationSuggestions.isEmpty &&
            _searchController.text.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No results found."),
          ),

        // 👥 Search Suggestions
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (_lawyerSuggestions.isNotEmpty) ...[
                const Text("Lawyers", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._lawyerSuggestions.map((lawyer) => ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(lawyer['displayName']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LawyerPreviewScreen(lawyerId: lawyer['id']),
                          ),
                        );
                      },
                    )),
                const SizedBox(height: 16),
              ],
              if (_specializationSuggestions.isNotEmpty) ...[
                const Text("Specializations", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._specializationSuggestions.map((spec) => ListTile(
                      leading: const Icon(Icons.gavel),
                      title: Text(spec['name']),
                      onTap: () {
                        // TODO: Filter lawyers by specialization
                      },
                    )),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
