import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autocomplete Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
      home: const ReceiptEntryScreen(),
    );
  }
}

class ReceiptEntryScreen extends StatefulWidget {
  const ReceiptEntryScreen({super.key});

  @override
  State<ReceiptEntryScreen> createState() => _ReceiptEntryScreenState();
}

class _ReceiptEntryScreenState extends State<ReceiptEntryScreen> {
  static const List<String> _products = <String>[
    'Apple',
    'Banana',
    'Orange',
    'Grape',
    'Pineapple',
    'Strawberry',
    'Watermelon',
  ];

  String? _selectedProduct;
  final FocusNode _brandFocus = FocusNode();
  final TextEditingController _brandController = TextEditingController();

  @override
  void dispose() {
    _brandController.dispose();
    _brandFocus.dispose();
    super.dispose();
  }

  void _onProductSelected(String selection) {
    setState(() {
      _selectedProduct = selection;
    });
    print('Selected product: $selection');
    FocusScope.of(context).requestFocus(_brandFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt Entry')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _products.where((String option) {
                  return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },

              // This is called when the user selects an item, either by
              // tapping it or by pressing Enter on a highlighted item.
              // This is the single source of truth for our selection logic.
              onSelected: (String selection) {
                _onProductSelected(selection);
              },

              fieldViewBuilder:
                  (
                    BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    return TextField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      decoration: const InputDecoration(labelText: 'Product'),

                      // ## THE FIX IS HERE ##
                      // Instead of writing our own logic, we just call the
                      // onFieldSubmitted callback provided by the Autocomplete builder.
                      // This callback is smart enough to know which item is highlighted.
                      onSubmitted: (_) {
                        onFieldSubmitted();
                      },
                    );
                  },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _brandController,
              focusNode: _brandFocus,
              decoration: const InputDecoration(labelText: 'Brand'),
              onSubmitted: (_) {
                print('Brand entered: ${_brandController.text}');
              },
            ),
          ],
        ),
      ),
    );
  }
}
