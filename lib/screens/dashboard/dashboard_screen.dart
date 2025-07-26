// File: lib/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../app_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define dashboard items
    final items = [
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
      // Masters
      _DashboardItem(
        title: 'Masters',
        icon: Icons.settings,
        route: AppRouter.mastersMenu, // new route
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService().signOut();
              // AuthGate will redirect back to Login
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pushNamed(context, item.route),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 48,
                      color: Theme.of(context).primaryColor,
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
            );
          },
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
