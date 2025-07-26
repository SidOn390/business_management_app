// File: lib/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              // AuthGate will redirect back to Login
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to your business dashboard!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
