import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_trial/cashier/success_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentScreen extends StatefulWidget {
  final int totalHarga;
  final List<Map<String, dynamic>> keranjang;

  PaymentScreen({required this.totalHarga, required this.keranjang});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  TextEditingController _uangDiterimaController = TextEditingController();

  void _terimaPembayaran() async {
    int uangDiterima = int.tryParse(_uangDiterimaController.text) ?? 0;
    if (uangDiterima < widget.totalHarga) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Uang yang diterima kurang')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Update stok
      for (var item in widget.keranjang) {
        var docRef = FirebaseFirestore.instance
            .collection('produk')
            .doc(item['id']);
        var snapshot = await docRef.get();
        if (snapshot.exists) {
          final currentStok = (snapshot.data()?['stok'] ?? 0).toInt();
          int newStok = currentStok - item['jumlah'];
          int fixedStok = newStok < 0 ? 0 : newStok;
          await docRef.update({'stok': fixedStok});
        }
      }

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
        'tanggal': DateTime.now(),
        'nominal': widget.totalHarga,
        'profit': totalProfit,
        'produk': widget.keranjang,
      });

      // 5. Simpan kode terakhir
      await kodeRef.set({'lastKode': nextKode});

      // 6. Navigasi ke Success Screen
      Navigator.pop(context);

      print("Data keranjang yg diteruskan: ${widget.keranjang}");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SuccessScreen(
                keranjang: widget.keranjang,
                totalHarga: widget.totalHarga,
                uangDiterima: uangDiterima,
              ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat menyimpan transaksi')),
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
          icon: Icon(Icons.arrow_back, color: Color(0xFF1E2939)),
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
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF3F4F6),
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
                  SizedBox(height: 8),
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
            SizedBox(height: 40),
            Text(
              'Uang yang diterima',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF364153),
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFD1D5DC)),
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
            Spacer(),
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
