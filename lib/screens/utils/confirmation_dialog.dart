import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Your Details"),
          content: const Text(
            "Please review and confirm that the details you entered are accurate. You may not be able to change some of this information later.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Confirm"),
            ),
          ],
        ),
      ) ??
      false;
}
