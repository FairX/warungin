// lib/widgets/transaction_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart'; // Import the model

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final bool isExpanded;
  final VoidCallback onToggleExpansion; // Callback to toggle expansion

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.isExpanded,
    required this.onToggleExpansion,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    bool isIncome = transaction.type == TransactionType.income;
    bool canExpand = transaction.items != null && transaction.items!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Add margin between cards
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Row ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side: Icon and Type
              Row(
                children: [
                  Icon(
                    isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isIncome ? Colors.green : Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isIncome ? "Pemasukkan" : "Pengeluaran",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // Right side: Amount and Expansion Button
              Row(
                children: [
                  Text(
                    currencyFormat.format(transaction.amount),
                    style: const TextStyle(
                      fontSize: 16, // Slightly smaller amount
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Expansion Button (only if details exist)
                  if (canExpand)
                    InkWell( // Make the icon tappable
                      onTap: onToggleExpansion, // Use the callback
                      child: Icon(
                        isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: Colors.black54,
                        size: 28,
                      ),
                    )
                  else
                    const SizedBox(width: 28), // Placeholder for alignment if no details
                ],
              )
            ],
          ),

          // --- Optional Description ---
          if (transaction.description.isNotEmpty && !isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 24), // Indent description
              child: Text(
                transaction.description,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // --- Collapsible Details ---
          if (canExpand && isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 12.0), // Add space before details
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (transaction.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
                       child: Text(
                         transaction.description,
                         style: const TextStyle(color: Colors.black54, fontSize: 14, fontStyle: FontStyle.italic),
                       ),
                    ),
                  // Item List
                  for (var item in transaction.items!)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${item.name} ( ${currencyFormat.format(item.price)} x ${item.quantity} )",
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            currencyFormat.format(item.total),
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  const Divider(height: 20, thickness: 0.5),
                  // Total Row within Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                        Text(
                          currencyFormat.format(transaction.amount), // Should match header amount
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}