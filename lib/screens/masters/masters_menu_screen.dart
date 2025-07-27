// File: lib/screens/masters/masters_menu_screen.dart

import 'package:flutter/material.dart';
import '../../app_router.dart';

class MastersMenuScreen extends StatelessWidget {
  const MastersMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = <_MasterItem>[
      _MasterItem(
        title: 'Cold Storages',
        icon: Icons.archive,
        route: AppRouter.coldStorageMaster,
      ),
      _MasterItem(
        title: 'Product Types',
        icon: Icons.category,
        route: AppRouter.productTypeMaster,
      ),
      _MasterItem(
        title: 'Brands',
        icon: Icons.branding_watermark,
        route: AppRouter.brandMaster,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Masters')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300, // Responsive: max tile width
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
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.1),
                        child: Icon(
                          item.icon,
                          size: 32,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
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
    );
  }
}

class _MasterItem {
  final String title;
  final IconData icon;
  final String route;

  const _MasterItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}
