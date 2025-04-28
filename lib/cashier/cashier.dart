import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart_screen.dart';

class CashierScreen extends StatefulWidget {
  @override
  _CashierScreenState createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  List<Map<String, dynamic>> keranjang = [];
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _tambahKeKeranjang(Map<String, dynamic> produk) async {
    setState(() {
      var existingItem = keranjang.firstWhere(
        (item) => item['nama'] == produk['nama'],
        orElse: () => {},
      );

      if (existingItem.isNotEmpty) {
        existingItem['jumlah'] += 1;
      } else {
        keranjang.add({
          'kode': produk['kode'],
          'nama': produk['nama'],
          'harga_jual': produk['harga_jual'],
          'jumlah': 1,
        });
      }
    });

    // Update stok di Firestore
    await FirebaseFirestore.instance
        .collection('produk')
        .doc(produk['id'])
        .update({'stok': produk['stok'] - 1});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -24,
            left: 0,
            right: 0,
            child: Container(
              height: 139,
              decoration: BoxDecoration(
                color: Colors.lightBlue[400],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      "Kasir",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: 335,
                  height: 47,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFD1D5DC)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 16),
                      Icon(Icons.search, color: Color(0xFF99A1AF), size: 16),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value.toLowerCase();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Cari Produk",
                            hintStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Color(0xFF99A1AF),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('produk')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "Belum Ada Produk",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF364153),
                          ),
                        ),
                      );
                    }

                    final produkList =
                        snapshot.data!.docs
                            .map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return {
                                'id': doc.id,
                                'nama': data['nama'] ?? '',
                                'harga_jual': data['harga_jual'] ?? 0,
                                'stok': data['stok'] ?? 0,
                              };
                            })
                            .where((produk) {
                              return produk['nama'].toLowerCase().contains(
                                searchQuery,
                              );
                            })
                            .toList();

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      itemCount: produkList.length,
                      itemBuilder: (context, index) {
                        final produk = produkList[index];
                        return GestureDetector(
                          onTap: () {
                            if (produk['stok'] > 0) {
                              _tambahKeKeranjang(produk);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6, // diperkecil padding antar item
                            ),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFD9D9D9),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          produk['nama'],
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Color(0xFF364153),
                                          ),
                                        ),
                                        Text(
                                          "Rp${produk['harga_jual']}",
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
                                    produk['stok'].toString(),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.lightBlue[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue[400],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartScreen(keranjang: keranjang),
            ),
          );
        },
        child: Icon(Icons.shopping_cart, color: Colors.white),
      ),
    );
  }
}
