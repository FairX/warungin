// lib/models/transaction.dart

// Enum to define the type of transaction
enum TransactionType { income, expense }

// Represents a single transaction item (e.g., part of an income transaction)
class TransactionItem {
  final String name;
  final int quantity;
  final double price;

  TransactionItem({required this.name, required this.quantity, required this.price});

  double get total => price * quantity;
}

// Represents a financial transaction (either income or expense)
class Transaction {
  final String id; // Unique ID for managing expansion state and potentially keys
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String description; // Optional description
  final List<TransactionItem>? items; // Optional list of items for detailed income/expense

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.description = '',
    this.items,
  });
}