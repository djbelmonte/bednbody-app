import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  final color = isError ? Colors.red.shade600 : Colors.green.shade600;
  final icon = isError ? Icons.error : Icons.check_circle;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ),
  );
}
