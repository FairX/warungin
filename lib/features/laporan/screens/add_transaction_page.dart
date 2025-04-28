// lib/screens/add_transaction_page.dart

import 'package:flutter/material.dart';
import '../models/transaction.dart'; // Import model

// Renamed class
class AddTransactionPage extends StatefulWidget {
  // Added const constructor
  const AddTransactionPage({super.key});

  @override
  // Renamed state class
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

// Renamed state class
class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  // --- State variable to track selected transaction type ---
  TransactionType _selectedType = TransactionType.income; // Default to income

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Renamed function
  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final amountString = _amountController.text.replaceAll('.', '').replaceAll(',', ''); // Remove thousand separators
      final amount = double.tryParse(amountString);
      final description = _descriptionController.text;

      if (amount != null && amount > 0) {
        final newTransaction = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          // --- Use the selected type from state ---
          type: _selectedType,
          amount: amount,
          date: DateTime.now(),
          description: description,
        );
        // Pop the page and return the new transaction data
        Navigator.pop(context, newTransaction);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan jumlah yang valid.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // --- Dynamic AppBar Title ---
        title: Text(_selectedType == TransactionType.income
            ? "Tambah Pemasukkan"
            : "Tambah Pengeluaran"),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Transaction Type Selector ---
              SegmentedButton<TransactionType>(
                segments: const <ButtonSegment<TransactionType>>[
                  ButtonSegment<TransactionType>(
                      value: TransactionType.income,
                      label: Text('Pemasukkan'),
                      icon: Icon(Icons.arrow_upward)),
                  ButtonSegment<TransactionType>(
                      value: TransactionType.expense,
                      label: Text('Pengeluaran'),
                      icon: Icon(Icons.arrow_downward)),
                ],
                selected: <TransactionType>{_selectedType}, // Use a Set for selected
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    // Update the state based on the new selection (should only be one)
                    _selectedType = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                   selectedBackgroundColor: _selectedType == TransactionType.income
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                   selectedForegroundColor: _selectedType == TransactionType.income
                      ? Colors.green.shade900
                      : Colors.red.shade900,
                   foregroundColor: Colors.grey.shade600,
                   // minimumSize: Size(double.infinity, 40), // Make buttons wider
                ),
              ),
              const SizedBox(height: 24), // Increased spacing

              // --- Amount Field ---
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: "Jumlah (Rp)",
                  prefixText: "Rp ",
                  border: const OutlineInputBorder(),
                  hintText: "Contoh: 50000",
                  // Change border color based on type? Optional.
                  // focusedBorder: OutlineInputBorder(
                  //   borderSide: BorderSide(
                  //     color: _selectedType == TransactionType.income ? Colors.green : Colors.red,
                  //     width: 2.0,
                  //   ),
                  // ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  final number = double.tryParse(value.replaceAll('.', '').replaceAll(',', ''));
                  if (number == null || number <= 0) {
                    return 'Masukkan jumlah angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- Description Field ---
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Deskripsi", // Simplified label
                  border: const OutlineInputBorder(),
                  hintText: _selectedType == TransactionType.income
                      ? "Contoh: Penjualan Harian"
                      : "Contoh: Beli Stok ATK", // Dynamic hint
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
              ),

              const Spacer(), // Pushes button to the bottom

              // --- Save Button ---
              ElevatedButton.icon( // Use ElevatedButton.icon
                icon: const Icon(Icons.save), // Add save icon
                label: const Text("Simpan"),
                onPressed: _saveTransaction, // Call the renamed function
                style: ElevatedButton.styleFrom(
                  // --- Dynamic Button Color ---
                  backgroundColor: _selectedType == TransactionType.income
                      ? Colors.green // Green for income
                      : Colors.redAccent, // Red for expense
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}