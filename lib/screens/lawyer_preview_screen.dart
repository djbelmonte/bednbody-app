import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'consultation_booking_screen.dart';

class LawyerPreviewScreen extends StatefulWidget {
  final String lawyerId;

  const LawyerPreviewScreen({super.key, required this.lawyerId});

  @override
  State<LawyerPreviewScreen> createState() => _LawyerPreviewScreenState();
}

class _LawyerPreviewScreenState extends State<LawyerPreviewScreen> {
  Map<String, dynamic>? _lawyerData;
  List<String> _specializationNames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLawyerDetails();
  }

  Future<void> _fetchLawyerDetails() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.lawyerId)
        .get();

    final userData = userDoc.data();
    if (userData == null) return;

    final List<String> specializationIds =
        List<String>.from(userData['specializations'] ?? []);

    // Fetch names of specializations
    final specsSnapshot = await FirebaseFirestore.instance
        .collection('law_specializations')
        .get();

    final allSpecs = specsSnapshot.docs
        .map((doc) => {'id': doc.id, 'name': doc['name']})
        .toList();

    final names = specializationIds.map((id) {
      final spec = allSpecs.firstWhere(
        (s) => s['id'] == id,
        orElse: () => {'name': 'Unknown'},
      );
      return spec['name']!;
    }).toList();

    setState(() {
      _lawyerData = userData;
      _specializationNames = List<String>.from(names);
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
        "${_lawyerData?['first_name'] ?? ''} ${_lawyerData?['middle_name'] ?? ''} ${_lawyerData?['last_name'] ?? ''}".trim();
    final yearGraduated = _lawyerData?['year_graduated'] ?? '';
    final yearsExp = _calculateYearsOfExperience(yearGraduated);

    return Scaffold(
      appBar: AppBar(title: const Text("Lawyer Preview")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fullName,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            const Text("Specializations:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ..._specializationNames.map((spec) => Text("• $spec")),
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
                        lawyerId: widget.lawyerId,
                        lawyerName: fullName,
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
