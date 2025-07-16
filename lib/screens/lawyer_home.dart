import 'package:flutter/material.dart';
import 'lawyer_dashboard_screen.dart';
import 'lawyer_profile_screen.dart';
// import 'lawyer_bookings_screen.dart';
// import 'lawyer_session_screen.dart';

class LawyerHomeScreen extends StatefulWidget {
  const LawyerHomeScreen({super.key});

  @override
  State<LawyerHomeScreen> createState() => _LawyerHomeScreenState();
}

class _LawyerHomeScreenState extends State<LawyerHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const LawyerDashboardScreen(),
    const LawyerProfileScreen(),
    // const LawyerBookingsScreen(),
    // const LawyerSessionScreen(),
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
