import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth_provider.dart';
import 'login_screen.dart';
import 'admin_shell.dart';

/// Shows the login form until the stored JWT is confirmed valid, then the
/// full 7-tab admin dashboard.
class AdminEntryScreen extends StatelessWidget {
  const AdminEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.loading) return const Center(child: CircularProgressIndicator());
    return auth.isAuthenticated ? const AdminShell() : const LoginScreen();
  }
}
