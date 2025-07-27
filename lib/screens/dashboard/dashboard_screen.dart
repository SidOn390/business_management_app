// File: lib/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../app_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract username from email
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final username = email.contains('@') ? email.split('@').first : email;
    final greeting = 'Hello, $username';

    final items = <_DashboardItem>[
      _DashboardItem(
        title: 'Receipt Entry',
        icon: Icons.receipt_long,
        route: AppRouter.receiptEntry,
      ),
      _DashboardItem(
        title: 'Receipt List',
        icon: Icons.list_alt,
        route: AppRouter.receiptList,
      ),
      _DashboardItem(
        title: 'Delivery Entry',
        icon: Icons.delivery_dining,
        route: AppRouter.deliveryEntry,
      ),
      _DashboardItem(
        title: 'Delivery History',
        icon: Icons.history,
        route: AppRouter.deliveryHistory,
      ),
      _DashboardItem(
        title: 'Billing Checker',
        icon: Icons.payment,
        route: AppRouter.billingChecker,
      ),
      _DashboardItem(
        title: 'Reports',
        icon: Icons.picture_as_pdf,
        route: AppRouter.reports,
      ),
      _DashboardItem(
        title: 'Masters',
        icon: Icons.settings,
        route: AppRouter.mastersMenu,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService().signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300, // Responsive: tiles max width 300px
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.pushNamed(context, item.route),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: 48,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final String route;

  const _DashboardItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}
