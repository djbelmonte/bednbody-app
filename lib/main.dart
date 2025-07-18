import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_signup_screen.dart';

import 'screens/utils/seed_branches.dart';
import 'screens/utils/seed_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // await seedBranches();
  // await seedServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bednbody App',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Nunito',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF0B2F25),
          primary: Color(0xFF0B2F25),
          secondary: Color(0xFFFFD700), // gold
          surface: Colors.white,
          error: Color(0xFFEF4444),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B2F25),
          foregroundColor: Color(0xFFFFD700),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.black),
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B2F25), // dark green
            foregroundColor: const Color(0xFFFFD700),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}
