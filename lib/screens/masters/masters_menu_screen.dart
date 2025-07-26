// File: lib/screens/masters/masters_menu_screen.dart

import 'package:flutter/material.dart';
import '../../app_router.dart';

class MastersMenuScreen extends StatelessWidget {
  const MastersMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final masters = [
      _MasterItem('Cold Storages', Icons.archive, AppRouter.coldStorageMaster),
      _MasterItem('Product Types', Icons.category, AppRouter.productTypeMaster),
      _MasterItem('Brands', Icons.branding_watermark, AppRouter.brandMaster),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Masters')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: masters.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) {
          final m = masters[i];
          return ListTile(
            leading: Icon(m.icon, color: Theme.of(context).primaryColor),
            title: Text(m.title),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, m.route),
          );
        },
      ),
    );
  }
}

class _MasterItem {
  final String title;
  final IconData icon;
  final String route;
  const _MasterItem(this.title, this.icon, this.route);
}
