import 'package:flutter/material.dart';
import 'therapist_dashboard_screen.dart';
import 'therapist_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_signup_screen.dart';
// import 'therapist_bookings_screen.dart';
// import 'therapist_session_screen.dart';

class TherapistHomeScreen extends StatefulWidget {
  const TherapistHomeScreen({super.key});

  @override
  State<TherapistHomeScreen> createState() => _TherapistHomeScreenState();
}

class _TherapistHomeScreenState extends State<TherapistHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TherapistDashboardScreen(),
    const TherapistProfileScreen(),
    // const TherapistBookingsScreen(),
    // const TherapistSessionScreen(),
  ];

  final List<String> _titles = [
    "Dashboard",
    "Profile",
    // "View Bookings",
    // "Session Room",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Log out",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.calendar_today),
          //   label: 'Bookings',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.video_call),
          //   label: 'Session',
          // ),
        ],
      ),
    );
  }
}
