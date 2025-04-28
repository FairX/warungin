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

  void _terimaPembayaran() {
    int uangDiterima = int.tryParse(_uangDiterimaController.text) ?? 0;
    if (uangDiterima >= widget.totalHarga) {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uang diterima kurang dari total tagihan')),
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
