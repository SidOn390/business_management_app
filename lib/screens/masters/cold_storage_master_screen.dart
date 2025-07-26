// File: lib/screens/masters/cold_storage_master_screen.dart

import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class ColdStorageMasterScreen extends StatefulWidget {
  const ColdStorageMasterScreen({super.key});

  @override
  State<ColdStorageMasterScreen> createState() =>
      _ColdStorageMasterScreenState();
}

class _ColdStorageMasterScreenState extends State<ColdStorageMasterScreen> {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _textCtrl = TextEditingController();
  String? _editingId;

  void _showDialog({String? id, String? initialName}) {
    _editingId = id;
    _textCtrl.text = initialName ?? '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(id == null ? 'Add Cold Storage' : 'Edit Cold Storage'),
        content: TextField(
          controller: _textCtrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _textCtrl.clear();
              _editingId = null;
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _textCtrl.text.trim();
              if (name.isEmpty) return;
              if (_editingId == null) {
                await _firestore.addColdStorage(name);
              } else {
                await _firestore.updateColdStorage(_editingId!, name);
              }
              _textCtrl.clear();
              _editingId = null;
              Navigator.of(dialogContext).pop();
            },
            child: Text(id == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Cold Storage'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.deleteColdStorage(id);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cold Storages')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestore.getColdStorages(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No entries yet.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final item = items[i];
              return ListTile(
                title: Text(item['name'] as String),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showDialog(
                        id: item['id'] as String,
                        initialName: item['name'] as String,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDelete(item['id'] as String),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
