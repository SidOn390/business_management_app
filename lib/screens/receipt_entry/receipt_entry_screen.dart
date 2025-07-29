// 📁 lib/screens/receipt_entry/receipt_entry_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import '../../services/master_service.dart';

class ReceiptEntryScreen extends StatefulWidget {
  const ReceiptEntryScreen({Key? key}) : super(key: key);

  @override
  State<ReceiptEntryScreen> createState() => _ReceiptEntryScreenState();
}

class _ReceiptEntryScreenState extends State<ReceiptEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;

  List<String> _coldStorages = [];
  List<String> _products = [];
  List<String> _brands = [];

  String? _coldValue;
  String? _productValue;
  String? _brandValue;
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _receiptController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _narrationController = TextEditingController();

  final FocusNode _dateFocus = FocusNode();
  final FocusNode _coldFocus = FocusNode();
  final FocusNode _productFocus = FocusNode();
  final FocusNode _brandFocus = FocusNode();
  final FocusNode _receiptFocus = FocusNode();
  final FocusNode _quantityFocus = FocusNode();
  final FocusNode _rateFocus = FocusNode();
  final FocusNode _narrationFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadMasters();
  }

  Future<void> _loadMasters() async {
    try {
      await MasterService.loadAllMasters();
      setState(() {
        _coldStorages = MasterService.coldStorages;
        _products = MasterService.products;
        _brands = MasterService.brands;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addMaster(
    String title,
    Future<void> Function(String) onAdd,
  ) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add New $title'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Enter $title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = ctrl.text.trim();
              if (val.isNotEmpty) {
                await onAdd(val);
                await _loadMasters();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Receipt saved')));
    _formKey.currentState!.reset();
    setState(() {
      _coldValue = null;
      _productValue = null;
      _brandValue = null;
      _selectedDate = DateTime.now();
    });
  }

  Widget _autocompleteField({
    required String label,
    required List<String> items,
    required String? value,
    required void Function(String) onSelected,
    required FocusNode focusNode,
    required FocusNode nextFocusNode,
    required Future<void> Function() onAdd,
  }) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: value ?? ''),
      optionsBuilder: (text) {
        if (text.text.isEmpty) return items;
        return items.where(
          (option) => option.toLowerCase().contains(text.text.toLowerCase()),
        );
      },
      onSelected: (selection) {
        onSelected(selection);
        FocusScope.of(context).requestFocus(nextFocusNode);
      },
      fieldViewBuilder: (context, ctrl, fn, onFieldSubmitted) {
        return RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (event) {
            if (event is RawKeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.enter) {
              final text = ctrl.text;
              final match = items.firstWhere(
                (item) => item.toLowerCase() == text.toLowerCase(),
                orElse: () => '',
              );
              if (match.isNotEmpty) {
                onSelected(match);
              }
              FocusScope.of(context).requestFocus(nextFocusNode);
            }
          },
          child: TextFormField(
            controller: ctrl,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onAdd,
              ),
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              final text = ctrl.text;
              final match = items.firstWhere(
                (item) => item.toLowerCase() == text.toLowerCase(),
                orElse: () => '',
              );
              if (match.isNotEmpty) {
                onSelected(match);
              }
              FocusScope.of(context).requestFocus(nextFocusNode);
            },
            validator: (v) =>
                (v == null || v.isEmpty) ? '$label required' : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt Entry')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      readOnly: true,
                      focusNode: _dateFocus,
                      controller: TextEditingController(
                        text: DateFormat('dd-MM-yyyy').format(_selectedDate),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _pickDate,
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_coldFocus),
                    ),
                    const SizedBox(height: 16),

                    _autocompleteField(
                      label: 'Cold Storage',
                      items: _coldStorages,
                      value: _coldValue,
                      onSelected: (v) => setState(() => _coldValue = v),
                      focusNode: _coldFocus,
                      nextFocusNode: _productFocus,
                      onAdd: () => _addMaster(
                        'Cold Storage',
                        MasterService.addColdStorage,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _autocompleteField(
                      label: 'Product',
                      items: _products,
                      value: _productValue,
                      onSelected: (v) => setState(() => _productValue = v),
                      focusNode: _productFocus,
                      nextFocusNode: _brandFocus,
                      onAdd: () =>
                          _addMaster('Product', MasterService.addProduct),
                    ),
                    const SizedBox(height: 16),

                    _autocompleteField(
                      label: 'Brand',
                      items: _brands,
                      value: _brandValue,
                      onSelected: (v) => setState(() => _brandValue = v),
                      focusNode: _brandFocus,
                      nextFocusNode: _receiptFocus,
                      onAdd: () => _addMaster('Brand', MasterService.addBrand),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _receiptController,
                      focusNode: _receiptFocus,
                      decoration: const InputDecoration(
                        labelText: 'Receipt Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_quantityFocus),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Receipt Number required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _quantityController,
                      focusNode: _quantityFocus,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_rateFocus),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Quantity required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _rateController,
                      focusNode: _rateFocus,
                      decoration: const InputDecoration(
                        labelText: 'Rate (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_narrationFocus),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _narrationController,
                      focusNode: _narrationFocus,
                      decoration: const InputDecoration(
                        labelText: 'Narration (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _save(),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save Receipt'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
