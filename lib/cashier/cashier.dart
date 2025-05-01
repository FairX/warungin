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
  List<Map<String, dynamic>> daftarProduk = [];
  bool isLoading = true;

  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  void _loadProduk() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('produk').get();

    final data =
        snapshot.docs.map((doc) {
          final item = doc.data();

          print(
            "Produk ID: ${doc.id}, Nama: ${item['nama']}, Harga Beli: ${item['harga_beli']}",
          );

          return {
            'id': doc.id,
            'nama': item['nama'],
            'harga_jual': item['harga_jual'],
            'harga_beli': item['harga_beli'],
            'stok': item['stok'],
            'stokTampil': item['stok'],
          };
        }).toList();

    setState(() {
      daftarProduk = data;
      isLoading = false;
    });
  }

  void _addtoKeranjang(Map<String, dynamic> produk) async {
    setState(() {
      final id = produk['id'];

      final index = daftarProduk.indexWhere((item) => item['id'] == id);
      if (index != -1 && daftarProduk[index]['stokTampil'] > 0) {
        daftarProduk[index]['stokTampil'] -= 1;

        final existing = keranjang.firstWhere(
          (item) => item['id'] == id,
          orElse: () => {},
        );

        if (existing.isNotEmpty) {
          existing['jumlah'] += 1;
        } else {
          keranjang.add({
            'id': produk['id'],
            'nama': produk['nama'],
            'harga_jual': produk['harga_jual'],
            'harga_beli': produk['harga_beli'],
            'jumlah': 1,
          });
          print(
            "Added to keranjang: ${produk['nama']}, Harga Jual: ${produk['harga_jual']}, Harga Beli: ${produk['harga_beli']}",
          );
        }

        print("Stok $id berkurang di tampilan");
      }
    });
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
                child:
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : daftarProduk.isEmpty
                        ? Center(child: Text("Belum Ada Produk"))
                        : ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          itemCount: daftarProduk.length,
                          itemBuilder: (context, index) {
                            final produk = daftarProduk[index];
                            if (!produk['nama'].toLowerCase().contains(
                              searchQuery,
                            ))
                              return SizedBox();

                            return GestureDetector(
                              onTap: () {
                                print("Added to cart: id = ${produk['id']}");
                                if (produk['stokTampil'] > 0) {
                                  _addtoKeranjang(produk);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 6,
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        color: Color(0xFFD9D9D9),
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
                                              ),
                                            ),
                                            Text(
                                              "Rp${produk['harga_jual']}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        produk['stokTampil'].toString(),
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
          ).then((_) {
            _loadProduk();
            keranjang.clear();
          });
        },
        child: Icon(Icons.shopping_cart, color: Colors.white),
      ),
    );
  }
}
