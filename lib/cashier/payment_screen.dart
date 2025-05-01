import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_trial/cashier/success_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentScreen extends StatefulWidget {
  final int totalHarga;
  final List<Map<String, dynamic>> keranjang;

  const PaymentScreen({
    super.key,
    required this.totalHarga,
    required this.keranjang,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _uangDiterimaController = TextEditingController();

  @override
  void dispose() {
    _uangDiterimaController.dispose(); // Dispose controller
    super.dispose();
  }

  void _terimaPembayaran() async {
    final int uangDiterima =
        int.tryParse(
          _uangDiterimaController.text.replaceAll('.', '').replaceAll(',', ''),
        ) ??
        0;
    if (uangDiterima < widget.totalHarga) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uang yang diterima kurang')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final List<Map<String, dynamic>> finalKeranjangData = List.from(
      widget.keranjang,
    );

    try {
      // 1. Update stok in Firestore
      WriteBatch batch =
          FirebaseFirestore.instance.batch(); // Use batch for atomic writes
      for (var item in finalKeranjangData) {
        final String? docId = item['id'] as String?;
        final int jumlahDibeli = item['jumlah'] as int? ?? 0;
        if (docId != null && jumlahDibeli > 0) {
          var docRef = FirebaseFirestore.instance
              .collection('produk')
              .doc(docId);
          // Note: Reading inside a loop isn't ideal for performance, but okay for moderate carts.
          // Consider fetching all product stocks beforehand if performance is critical.
          DocumentSnapshot snapshot =
              await docRef
                  .get(); // Consider error handling if doc doesn't exist
          if (snapshot.exists) {
            final currentStok =
                (snapshot.data() as Map<String, dynamic>?)?['stok'] as int? ??
                0;
            int newStok = currentStok - jumlahDibeli;
            batch.update(docRef, {'stok': newStok < 0 ? 0 : newStok});
          } else {
            print(
              "Warning: Product document ${docId} not found during stock update.",
            );
          }
        }
      }
      await batch.commit();

      // 2. Ambil nomor urut penjualan
      var kodeRef = FirebaseFirestore.instance
          .collection('metadata')
          .doc('penjualan');
      var kodeSnapshot = await kodeRef.get();
      int lastKode =
          (kodeSnapshot.exists ? (kodeSnapshot.data()?['lastKode'] ?? 0) : 0)
              .toInt();
      int nextKode = lastKode + 1;
      String formattedKode = nextKode.toString().padLeft(4, '0');

      // 3. Hitung total profit
      int totalProfit = 0;

      for (var item in widget.keranjang) {
        int beli = (item['harga_beli'] ?? 0).toInt();
        int jual = (item['harga_jual'] ?? 0).toInt();
        int jumlah = (item['jumlah'] ?? 0).toInt();

        print(
          "Item: ${item['nama']}, Harga Beli: $beli, Harga Jual: $jual, Jumlah: $jumlah",
        );

        int profitPerItem = (jual - beli) * jumlah;
        totalProfit += profitPerItem;
      }

      // 4. Simpan transaksi
      await FirebaseFirestore.instance.collection('transaksi').add({
        'kode': formattedKode,
        'tanggal': Timestamp.now(),
        'nominal': widget.totalHarga,
        'profit': totalProfit,
        'produk': finalKeranjangData,
      });

      // 5. Simpan kode terakhir
      await kodeRef.set({'lastKode': nextKode});

      // 6. Navigasi ke Success Screen
      if (!mounted) return; // Check before navigation
      Navigator.pop(context);

      print("Data keranjang yg diteruskan: ${widget.keranjang}");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SuccessScreen(
                keranjang: finalKeranjangData,
                totalHarga: widget.totalHarga,
                uangDiterima: uangDiterima,
              ),
        ),
      );
    } catch (e, s) {
      // Catch error and stack trace
      print("Error processing payment: $e\n$s"); // Log error and stack trace
      if (!mounted) return; // Check before context use
      Navigator.pop(context); // Ensure dialog is popped on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')), // Show error detail
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2939)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pembayaran',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF1E2939),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Tagihan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF364153),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp${widget.totalHarga}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00A6F4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Uang yang diterima',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF364153),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD1D5DC)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _uangDiterimaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Masukkan nominal',
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _terimaPembayaran,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00A6F4),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Terima',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
