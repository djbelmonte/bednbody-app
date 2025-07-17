import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'consultation_booking_screen.dart';

class TherapistPreviewScreen extends StatefulWidget {
  final String therapistId;

  const TherapistPreviewScreen({super.key, required this.therapistId});

  @override
  State<TherapistPreviewScreen> createState() => _TherapistPreviewScreenState();
}

class _TherapistPreviewScreenState extends State<TherapistPreviewScreen> {
  Map<String, dynamic>? _therapistData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTherapistDetails();
  }

  Future<void> _fetchTherapistDetails() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.therapistId)
        .get();

    final userData = userDoc.data();
    if (userData == null) return;

    setState(() {
      _therapistData = userData;
      _isLoading = false;
    });
  }

  int _calculateYearsOfExperience(String? yearGraduated) {
    if (yearGraduated == null || yearGraduated.isEmpty) return 0;
    final gradYear = int.tryParse(yearGraduated);
    final currentYear = DateTime.now().year;
    return gradYear != null ? (currentYear - gradYear) : 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final fullName =
        "${_therapistData?['first_name'] ?? ''} ${_therapistData?['middle_name'] ?? ''} ${_therapistData?['last_name'] ?? ''}".trim();
    final yearGraduated = _therapistData?['year_graduated'] ?? '';
    final yearsExp = _calculateYearsOfExperience(yearGraduated);

    return Scaffold(
      appBar: AppBar(title: const Text("Therapist Preview")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fullName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text("Years of Experience: $yearsExp"),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConsultationBookingScreen(
                        therapistId: widget.therapistId,
                        therapistName: fullName,
                      ),
                    ),
                  );
                },
                child: const Text("Book a Consultation"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
