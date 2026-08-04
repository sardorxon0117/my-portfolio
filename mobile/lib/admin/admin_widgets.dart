import 'package:flutter/material.dart';

/// Mirrors admin/admin.css's .card — a bordered section container used
/// throughout every admin tab.
class AdminCard extends StatelessWidget {
  final String title;
  final Widget child;
  const AdminCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 17)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

/// Mirrors admin.js's toast() — a brief bottom snackbar for save confirmations/errors.
void showAdminToast(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade700 : null,
      duration: const Duration(seconds: 3),
    ),
  );
}
