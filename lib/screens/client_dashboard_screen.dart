import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'choose_service_screen.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  String? _firstName;
  bool _isLoading = true;
  List<String> _branches = [];
  String? _selectedBranch;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchBranches();
  }

  Future<void> _fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _firstName = doc['first_name'] ?? 'there';
      _isLoading = false;
    });
  }

  Future<void> _fetchBranches() async {
    final snapshot = await FirebaseFirestore.instance.collection('branches').get();
    setState(() {
      _branches = snapshot.docs.map((doc) => doc['name'] as String).toList();
      if (_branches.isNotEmpty) {
        _selectedBranch = _branches.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = "Good Morning";
    } else if (hour < 18) {
      greeting = "Good Afternoon";
    } else {
      greeting = "Good Evening";
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: 1.0,
                curve: Curves.easeIn,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$greeting, $_firstName!",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 28,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Welcome back to your wellness space ✨",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 💆‍♀️ Booking Button + Branch Selector
              
              Row(
                children: [
                  SizedBox(
                    width: screenWidth * 0.4 - 24,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                        backgroundColor: const Color(0xFF0B2F25),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        if (_selectedBranch != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChooseServiceScreen(selectedBranch: _selectedBranch!),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please select a branch")),
                          );
                        }
                      },
                      child: const FittedBox(child: Text("Book a Massage")),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: screenWidth * 0.6 - 24,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Branch",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      value: _selectedBranch,
                      isExpanded: true, // ✅ this prevents dropdown width issues
                      items: _branches.map((branch) {
                        return DropdownMenuItem<String>(
                          value: branch,
                          child: Text(
                            branch,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBranch = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 🧘‍♀️ Premium Quote Section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: const Color(0xFFF1F5F9),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "“Relaxation is the art of letting go.”",
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "— Bednbody Wisdom",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 🧑‍💼 Top Therapists
              Text(
                "Top Therapists",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: PageView(
                  controller: PageController(viewportFraction: 1),
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey.shade300,
                        image: const DecorationImage(
                          image: AssetImage('assets/mock-therapist.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
