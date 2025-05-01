import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessScreen extends StatelessWidget {
  final List<Map<String, dynamic>> keranjang;
  final int totalHarga;
  final int uangDiterima;

  SuccessScreen({
    required this.keranjang,
    required this.totalHarga,
    required this.uangDiterima,
  });

  @override
  Widget build(BuildContext context) {
    int kembalian = uangDiterima - totalHarga;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 80),
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 16),
            Text(
              'Transaksi Berhasil!',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF364153),
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView(
                children:
                    keranjang.map((item) {
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
            _buildRow('Subtotal', 'Rp$totalHarga'),
            _buildRow('Uang Diterima', 'Rp$uangDiterima'),
            _buildRow('Kembalian', 'Rp$kembalian'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00A6F4),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Selesai',
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

  Widget _buildRow(String title, String value) {
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
