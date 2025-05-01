// lib/service/transaction_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_trial/features/laporan/models/transaction.dart' as laporan; // Use alias

class TransactionService {
  final CollectionReference _transactionCollection =
      FirebaseFirestore.instance.collection('transactions'); // Choose collection name

  // Add a new transaction (income or expense) to Firestore
  Future<void> addTransaction(laporan.Transaction transaction) async {
    try {
      // Convert our model to a Map suitable for Firestore
      Map<String, dynamic> data = {
        'type': transaction.type.toString(), // Store enum as string
        'amount': transaction.amount,
        'date': Timestamp.fromDate(transaction.date), // Use Firestore Timestamp
        'description': transaction.description,
        'items': transaction.items?.map((item) => { // Store items if they exist
          'name': item.name,
          'quantity': item.quantity,
          'price': item.price,
        }).toList(),
        // Add userId if you need user-specific transactions later
        // 'userId': FirebaseAuth.instance.currentUser?.uid,
      };
      await _transactionCollection.add(data);
    } catch (e) {
      print("Error adding transaction: $e");
      // Consider throwing the error or returning a status
      throw Exception('Failed to add transaction');
    }
  }

  // Get a stream of transactions (ordered by date descending)
  Stream<List<laporan.Transaction>> getTransactionsStream() {
    return _transactionCollection
        .orderBy('date', descending: true)
        // Add .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid) for user-specific data
        .snapshots()
        .map((snapshot) {
            return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp).toDate(); // Convert Timestamp to DateTime

            // Convert Firestore item map back to TransactionItem list
            List<laporan.TransactionItem>? items;
            if (data['items'] != null && data['items'] is List) {
              items = (data['items'] as List).map((itemData) {
                return laporan.TransactionItem(
                  name: itemData['name'] ?? '',
                  // Ensure quantity is int, price is double
                  quantity: (itemData['quantity'] as num?)?.toInt() ?? 0,
                  price: (itemData['price'] as num?)?.toDouble() ?? 0.0,
                );
              }).toList();
            }

            return laporan.Transaction(
              id: doc.id, // Use Firestore document ID
              // Convert string back to enum
              type: data['type'] == laporan.TransactionType.income.toString()
                  ? laporan.TransactionType.income
                  : laporan.TransactionType.expense,
              amount: (data['amount'] as num?)?.toDouble() ?? 0.0, // Ensure double
              date: date,
              description: data['description'] ?? '',
              items: items,
            );
            }).toList();
        });
  }

  // --- Optional: Add methods for filtering by date range, etc. ---
}