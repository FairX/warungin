import 'package:dashboard_trial/features/laporan/models/transaction.dart' as laporan; // Use alias
import 'package:dashboard_trial/service/transaction_service.dart'; // Import the service
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessScreen extends StatefulWidget {
  final List<Map<String, dynamic>> keranjang;
  final int totalHarga;
  final int uangDiterima;

  const SuccessScreen({ // Add const constructor
    super.key,
    required this.keranjang,
    required this.totalHarga,
    required this.uangDiterima,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  final TransactionService _transactionService = TransactionService(); // Instantiate service
  bool _isSaving = false; // Track saving state

  @override
  void initState() {
    super.initState();
    // Save the transaction automatically when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _saveIncomeTransaction();
    });
  }

  Future<void> _saveIncomeTransaction() async {
     if (_isSaving) return; // Prevent double saving
     setState(() => _isSaving = true);

     try {
       // Convert keranjang items to Laporan TransactionItem
       final List<laporan.TransactionItem> items = widget.keranjang.map((cartItem) {
         return laporan.TransactionItem(
           name: cartItem['nama'] ?? 'Unknown Item',
           quantity: (cartItem['jumlah'] as num?)?.toInt() ?? 0,
           // Ensure price is double
           price: (cartItem['harga_jual'] as num?)?.toDouble() ?? 0.0,
         );
       }).toList();

       // Create the Laporan Transaction
       final newIncome = laporan.Transaction(
         id: DateTime.now().millisecondsSinceEpoch.toString(), // Or use Firestore auto-ID
         type: laporan.TransactionType.income,
         amount: widget.totalHarga.toDouble(), // Ensure double
         date: DateTime.now(),
         description: 'Penjualan Kasir', // Generic description
         items: items, // Include the list of items sold
       );

       // Save using the service
       await _transactionService.addTransaction(newIncome);
       print('Income transaction saved successfully!');
       // Optionally show a success message (different from transaction success)
       // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Laporan diperbarui.')));

     } catch (e) {
        print('Error saving income transaction: $e');
        // Show error message to user
        if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan ke laporan: $e')));
        }
     } finally {
        if(mounted) {
          setState(() => _isSaving = false);
        }
     }
  }

  @override
  Widget build(BuildContext context) {
    int kembalian = widget.uangDiterima - widget.totalHarga;

    return Scaffold(
      // ... (rest of your existing SuccessScreen UI remains the same)
       backgroundColor: Colors.white,
       body: Padding(
         padding: const EdgeInsets.all(20),
         child: Column(
           children: [
             SizedBox(height: 80),
             Icon(Icons.check_circle, color: Colors.green, size: 80),
             SizedBox(height: 16),
             Text('Transaksi Berhasil!', /*...*/),
             SizedBox(height: 24),
             Expanded(
              child: ListView( // Provide the ListView as the child
                children: widget.keranjang.map((item) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item['nama'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF364153),
                      ),
                    ),
                    subtitle: Text(
                      '${item['jumlah']} x Rp${item['harga_jual']}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    trailing: Text(
                      'Rp${item['jumlah'] * item['harga_jual']}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF364153),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
             Divider(),
             SizedBox(height: 8),
             _buildRow('Subtotal', 'Rp${widget.totalHarga}'),
             _buildRow('Uang Diterima', 'Rp${widget.uangDiterima}'),
             _buildRow('Kembalian', 'Rp$kembalian'),
             SizedBox(height: 20),
             ElevatedButton(
               onPressed: _isSaving ? null : () { // Disable button while saving
                 Navigator.popUntil(context, (route) => route.isFirst);
               },
               // ... (button style)
               child: _isSaving
                   ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,))
                   : const Text('Selesai', /*...*/),
             ),
           ],
         ),
       ),
    );
  }

  Widget _buildRow(String title, String value) {
    // ... (existing _buildRow method)
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 4),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
           Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
         ],
       ),
     );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     int kembalian = uangDiterima - totalHarga;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             SizedBox(height: 80),
//             Icon(Icons.check_circle, color: Colors.green, size: 80),
//             SizedBox(height: 16),
//             Text(
//               'Transaksi Berhasil!',
//               style: GoogleFonts.poppins(
//                 fontSize: 22,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF364153),
//               ),
//             ),
//             SizedBox(height: 24),
//             Expanded(
//               child: ListView(
//                 children:
//                     keranjang.map((item) {
//                       return ListTile(
//                         contentPadding: EdgeInsets.zero,
//                         title: Text(
//                           item['nama'],
//                           style: GoogleFonts.poppins(
//                             fontWeight: FontWeight.w500,
//                             color: Color(0xFF364153),
//                           ),
//                         ),
//                         subtitle: Text(
//                           '${item['jumlah']} x Rp${item['harga_jual']}',
//                           style: GoogleFonts.poppins(fontSize: 12),
//                         ),
//                         trailing: Text(
//                           'Rp${item['jumlah'] * item['harga_jual']}',
//                           style: GoogleFonts.poppins(
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF364153),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//               ),
//             ),
//             Divider(),
//             SizedBox(height: 8),
//             _buildRow('Subtotal', 'Rp$totalHarga'),
//             _buildRow('Uang Diterima', 'Rp$uangDiterima'),
//             _buildRow('Kembalian', 'Rp$kembalian'),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.popUntil(context, (route) => route.isFirst);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xFF00A6F4),
//                 padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//               child: Text(
//                 'Selesai',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
//           Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
// }
