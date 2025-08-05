import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:business_management_app/services/firestore_service.dart';

class ReceiptEntryScreen extends StatefulWidget {
  const ReceiptEntryScreen({super.key});

  @override
  State<ReceiptEntryScreen> createState() => _ReceiptEntryScreenState();
}

class _ReceiptEntryScreenState extends State<ReceiptEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  final _receiptNumberController = TextEditingController();
  final _coldStorageController = TextEditingController();
  final _productController = TextEditingController();
  final _brandController = TextEditingController();
  final _quantityController = TextEditingController();
  final _rateController = TextEditingController();
  final _narrationController = TextEditingController();
  final _dateController = TextEditingController();

  final _receiptNumberFocusNode = FocusNode();
  final _coldStorageFocusNode = FocusNode();
  final _dateFocusNode = FocusNode();
  final _productFocusNode = FocusNode();
  final _brandFocusNode = FocusNode();
  final _quantityFocusNode = FocusNode();
  final _rateFocusNode = FocusNode();
  final _narrationFocusNode = FocusNode();
  final _saveButtonFocusNode = FocusNode();

  DateTime _selectedDate = DateTime.now();
  String? _selectedColdStorage;
  String? _selectedProduct;
  String? _selectedBrand;

  List<String> _coldStorageOptions = [];
  List<String> _productOptions = [];
  List<String> _brandOptions = [];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd-MM-yy').format(_selectedDate);
    _fetchMasterData();
  }

  @override
  void dispose() {
    _receiptNumberController.dispose();
    _coldStorageController.dispose();
    _productController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    _rateController.dispose();
    _narrationController.dispose();
    _dateController.dispose();

    _receiptNumberFocusNode.dispose();
    _coldStorageFocusNode.dispose();
    _dateFocusNode.dispose();
    _productFocusNode.dispose();
    _brandFocusNode.dispose();
    _quantityFocusNode.dispose();
    _rateFocusNode.dispose();
    _narrationFocusNode.dispose();
    _saveButtonFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchMasterData() async {
    try {
      final storagesList = await _firestoreService.getColdStorages().first;
      final productsList = await _firestoreService.getProducts().first;
      final brandsList = await _firestoreService.getBrands().first;

      setState(() {
        _coldStorageOptions = storagesList
            .map((map) => map['name'] as String)
            .toList();
        _productOptions = productsList
            .map((map) => map['name'] as String)
            .toList();
        _brandOptions = brandsList.map((map) => map['name'] as String).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching master data: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd-MM-yy').format(_selectedDate);
      });
      FocusScope.of(context).requestFocus(_productFocusNode);
    }
  }

  Future<void> _saveReceipt() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final receiptNumber = _receiptNumberController.text;
      final coldStorage = _selectedColdStorage!;
      final bool isDuplicate = await _firestoreService.doesReceiptExist(
        receiptNumber,
        coldStorage,
      );

      if (isDuplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: Receipt #$receiptNumber already exists for $coldStorage.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      final int quantity = int.parse(_quantityController.text);
      final receiptData = {
        'receiptNumber': receiptNumber,
        'coldStorageName': coldStorage,
        'inwardDate': Timestamp.fromDate(_selectedDate),
        'productName': _selectedProduct,
        'brandName': _selectedBrand,
        'inwardQuantity': quantity,
        'remainingQuantity': quantity,
        'rate': double.parse(_rateController.text),
        'narration': _narrationController.text.trim(),
        'isPaid': false,
        'status': 'Active',
      };

      debugPrint('--- SAVING RECEIPT DATA ---');
      debugPrint(receiptData.toString());
      debugPrint('---------------------------');

      // await _firestoreService.addReceipt(receiptData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt data printed to console!'),
            backgroundColor: Colors.blue,
          ),
        );
      }

      _formKey.currentState!.reset();
      _receiptNumberController.clear();
      _coldStorageController.clear();
      _productController.clear();
      _brandController.clear();
      setState(() {
        _selectedDate = DateTime.now();
        _dateController.text = DateFormat('dd-MM-yy').format(_selectedDate);
        _selectedColdStorage = null;
        _selectedProduct = null;
        _selectedBrand = null;
      });
      FocusScope.of(context).requestFocus(_receiptNumberFocusNode);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing receipt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Receipt Entry')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _receiptNumberController,
                      focusNode: _receiptNumberFocusNode,
                      autofocus: true, // BUG FIX 4: Initial focus
                      decoration: const InputDecoration(
                        labelText: 'Receipt Number',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a receipt number'
                          : null,
                      onFieldSubmitted: (_) => FocusScope.of(
                        context,
                      ).requestFocus(_coldStorageFocusNode),
                    ),
                    const SizedBox(height: 16),
                    _buildAutocompleteField(
                      focusNode: _coldStorageFocusNode,
                      controller: _coldStorageController,
                      labelText: 'Cold Storage',
                      options: _coldStorageOptions,
                      onSelected: (selection) {
                        setState(() {
                          _selectedColdStorage = selection;
                          _coldStorageController.text = selection;
                        });
                        FocusScope.of(context).requestFocus(_dateFocusNode);
                      },
                      nextFocusNode: _dateFocusNode,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      focusNode: _dateFocusNode,
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Inward Date',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter a date';
                        try {
                          DateFormat('dd-MM-yy').parseStrict(value);
                          return null;
                        } catch (e) {
                          return 'Invalid format (dd-MM-yy)';
                        }
                      },
                      onChanged: (value) {
                        try {
                          final date = DateFormat(
                            'dd-MM-yy',
                          ).parseStrict(value);
                          setState(() => _selectedDate = date);
                        } catch (e) {
                          /* Ignore parsing errors while typing */
                        }
                      },
                      onFieldSubmitted: (_) => FocusScope.of(
                        context,
                      ).requestFocus(_productFocusNode),
                    ),
                    const SizedBox(height: 16),
                    _buildAutocompleteField(
                      focusNode: _productFocusNode,
                      controller: _productController,
                      labelText: 'Product',
                      options: _productOptions,
                      onSelected: (selection) {
                        setState(() {
                          _selectedProduct = selection;
                          _productController.text = selection;
                        });
                        FocusScope.of(context).requestFocus(_brandFocusNode);
                      },
                      nextFocusNode: _brandFocusNode,
                    ),
                    const SizedBox(height: 16),
                    _buildAutocompleteField(
                      focusNode: _brandFocusNode,
                      controller: _brandController,
                      labelText: 'Brand',
                      options: _brandOptions,
                      onSelected: (selection) {
                        setState(() {
                          _selectedBrand = selection;
                          _brandController.text = selection;
                        });
                        FocusScope.of(context).requestFocus(_quantityFocusNode);
                      },
                      nextFocusNode: _quantityFocusNode,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      focusNode: _quantityFocusNode,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter quantity'
                          : null,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_rateFocusNode),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _rateController,
                      focusNode: _rateFocusNode,
                      decoration: const InputDecoration(labelText: 'Rate'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a rate'
                          : null,
                      onFieldSubmitted: (_) => FocusScope.of(
                        context,
                      ).requestFocus(_narrationFocusNode),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _narrationController,
                      focusNode: _narrationFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Narration (Optional)',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      textInputAction: TextInputAction
                          .next, // BUG FIX 3: Change enter key behavior
                      onFieldSubmitted: (_) => FocusScope.of(
                        context,
                      ).requestFocus(_saveButtonFocusNode),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      focusNode: _saveButtonFocusNode,
                      onPressed: _isSaving ? null : _saveReceipt,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Receipt'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAutocompleteField({
    required FocusNode focusNode,
    required TextEditingController controller,
    required String labelText,
    required List<String> options,
    required ValueChanged<String> onSelected,
    required FocusNode nextFocusNode,
  }) {
    return RawAutocomplete<String>(
      focusNode: focusNode,
      textEditingController: controller,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      onSelected: onSelected,
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextFormField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(labelText: labelText),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please select a $labelText';
                if (!options.contains(value))
                  return 'Please select a valid $labelText from the list';
                return null;
              },
              onFieldSubmitted: (_) {
                onFieldSubmitted();
                FocusScope.of(context).requestFocus(nextFocusNode);
              },
            );
          },
      optionsViewBuilder:
          (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      // BUG FIX 1: Use a ListTile for highlighting
                      return ListTile(
                        title: Text(option),
                        onTap: () => onSelected(option),
                        tileColor:
                            AutocompleteHighlightedOption.of(context) == index
                            ? Theme.of(context).focusColor.withOpacity(0.1)
                            : null,
                      );
                    },
                  ),
                ),
              ),
            );
          },
    );
  }
}
