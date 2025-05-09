import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_trial/cashier/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> keranjang;

  CartScreen({required this.keranjang});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _hitungTotalItem() {
    return widget.keranjang.fold<int>(
      0,
      (sum, item) => sum + (item['jumlah'] as int),
    );
  }

  int _hitungTotalHarga() {
    return widget.keranjang.fold<int>(
      0,
      (sum, item) =>
          sum + ((item['harga_jual'] as int) * (item['jumlah'] as int)),
    );
  }

  void _batal() {
    setState(() {
      widget.keranjang.clear();
    });
    Navigator.pop(context);
  }

  void _bayar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PaymentScreen(
              keranjang: widget.keranjang,
              totalHarga: _hitungTotalHarga(),
            ),
      ),
    ).then((_) {
      setState(() {
        widget.keranjang.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF364153)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Keranjang",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.grey[800],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          widget.keranjang.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Keranjang Kosong",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF364153),
                      ),
                    ),
                    Text(
                      "Tambahkan produk dari halaman Kasir.",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFF364153),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      itemCount: widget.keranjang.length,
                      itemBuilder: (context, index) {
                        final item = widget.keranjang[index];
                        final int hargaJual = item['harga_jual'] as int? ?? 0;
                        final int jumlah = item['jumlah'] as int? ?? 0;
                        final int totalItem = hargaJual * jumlah;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['nama'] ?? 'Nama Tidak Ditemukan',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Color(0xFF364153),
                                      ),
                                    ),
                                    Text(
                                      "Rp$hargaJual x $jumlah",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Color(0xFF364153),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "Rp$totalItem",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Color(0xFF364153),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "TOTAL (${_hitungTotalItem()})",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFF364153),
                              ),
                            ),
                            Text(
                              "Rp${_hitungTotalHarga()}",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFF364153),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _batal,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Color(0xFF00A6F4)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(
                                  "Batal",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF00A6F4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _bayar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF00A6F4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(
                                  "Bayar",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
