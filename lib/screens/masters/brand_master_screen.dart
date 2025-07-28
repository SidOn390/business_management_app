// File: lib/screens/masters/brand_master_screen.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/firestore_service.dart';

class BrandMasterScreen extends StatefulWidget {
  const BrandMasterScreen({Key? key}) : super(key: key);

  @override
  _BrandMasterScreenState createState() => _BrandMasterScreenState();
}

class _BrandMasterScreenState extends State<BrandMasterScreen> {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _textCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  String? _editingId;
  String _searchQuery = '';
  bool _isProcessing = false;
  final RegExp _validName = RegExp(r"^[a-zA-Z0-9 &-]+$");

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
      () => setState(() => _searchQuery = _searchCtrl.text.trim()),
    );
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  SnackBar _snack(String message, Color background) => SnackBar(
    content: Text(message),
    backgroundColor: background,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDialog({String? id, String? initialName}) async {
    _editingId = id;
    _textCtrl.text = initialName ?? '';
    _isProcessing = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) {
            final name = _textCtrl.text.trim();
            final canSubmit = name.isNotEmpty && !_isProcessing;
            return AlertDialog(
              title: Text(id == null ? 'Add Brand' : 'Edit Brand'),
              content: TextField(
                controller: _textCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Brand Name',
                  errorText: errorText,
                  errorMaxLines: 2,
                ),
                onChanged: (_) => setState(() => errorText = null),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _editingId = null;
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: !canSubmit
                      ? null
                      : () async {
                          setState(() => _isProcessing = true);
                          final name = _textCtrl.text.trim();
                          if (!_validName.hasMatch(name)) {
                            setState(() {
                              errorText =
                                  'Only letters, numbers, spaces, & and - allowed';
                              _isProcessing = false;
                            });
                            return;
                          }
                          try {
                            final existing = await _firestore.getBrands().first;
                            final lowerNames = existing
                                .map((e) => (e['name'] as String).toLowerCase())
                                .toList();
                            if (id == null) {
                              if (lowerNames.contains(name.toLowerCase())) {
                                setState(() {
                                  errorText = 'This brand already exists';
                                  _isProcessing = false;
                                });
                                return;
                              }
                              await _firestore.addBrand(name);
                              ScaffoldMessenger.of(context).showSnackBar(
                                _snack(
                                  'Brand Added successfully',
                                  Colors.green,
                                ),
                              );
                            } else {
                              final original =
                                  existing.firstWhere(
                                        (e) => e['id'] == id,
                                      )['name']
                                      as String;
                              if (original.toLowerCase() !=
                                      name.toLowerCase() &&
                                  lowerNames.contains(name.toLowerCase())) {
                                setState(() {
                                  errorText = 'This brand already exists';
                                  _isProcessing = false;
                                });
                                return;
                              }
                              await _firestore.updateBrand(id, name);
                              ScaffoldMessenger.of(context).showSnackBar(
                                _snack(
                                  'Brand Updated successfully',
                                  Colors.blue,
                                ),
                              );
                            }
                            Navigator.of(ctx).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: \$e')),
                            );
                          } finally {
                            setState(() => _isProcessing = false);
                          }
                        },
                  child: Text(id == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Brand'),
        content: const Text('Are you sure you want to delete this brand?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _firestore.deleteBrand(id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_snack('Brand Deleted successfully', Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Brands')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search brands…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _firestore.getBrands(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error, size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          Text('Error: \${snap.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => setState(() {}),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (snap.connectionState == ConnectionState.waiting) {
                    return _buildShimmer();
                  }
                  final items = (snap.data ?? [])
                      .where(
                        (e) => (e['name'] as String).toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                      )
                      .toList();
                  items.sort(
                    (a, b) => (a['name'] as String).toLowerCase().compareTo(
                      (b['name'] as String).toLowerCase(),
                    ),
                  );
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No brands yet'),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return ListTile(
                        title: Text(item['name'] as String),
                        onTap: () => _showDialog(
                          id: item['id'] as String,
                          initialName: item['name'] as String,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit ${item['name']}',
                              onPressed: () => _showDialog(
                                id: item['id'] as String,
                                initialName: item['name'] as String,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Delete ${item['name']}',
                              onPressed: () =>
                                  _confirmDelete(item['id'] as String),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        tooltip: 'Add Brand',
        child: const Icon(Icons.add),
      ),
    );
  }
}
