import 'package:dashboard_trial/service/product_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_add.dart';

class ProdukScreen extends StatefulWidget {
  @override
  _ProdukScreenState createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  final ProductService _productService = ProductService();
  List<Map<String, dynamic>> _produkList = [];
  List<Map<String, dynamic>> _filteredProdukList = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredProdukList = _produkList;
    _searchController.addListener(_filterProduk);
    _getProdukFromFirestore();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isLoading = true;

  Future<void> _getProdukFromFirestore() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Map<String, dynamic>> produk =
          await _productService.getAllProducts();
      setState(() {
        _produkList = produk;
        _filteredProdukList = produk;
        _isLoading = false;
      });
    } catch (e) {
      print('Error mengambil data produk: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterProduk() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProdukList =
          _produkList.where((produk) {
            return produk['nama'].toLowerCase().contains(query);
          }).toList();
    });
  }

  void _tambahProduk(Map<String, dynamic> produk) async {
    try {
      //await _productService.addProduct(produk);
      await _getProdukFromFirestore();
    } catch (e) {
      print('Error menambahkan produk: $e');
    }
  }

  void _editProduk(int index, Map<String, dynamic> produkBaru) async {
    try {
      String id = _filteredProdukList[index]['id'];
      await _productService.updateProduct(id, {
        'nama': produkBaru['nama'],
        'harga_jual': produkBaru['harga_jual'],
        'stok': produkBaru['stok'],
      });
      _getProdukFromFirestore();
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  void _hapusProduk(int index) async {
    try {
      String id = _filteredProdukList[index]['id'];
      await _productService.deleteProduct(id);
      _getProdukFromFirestore();
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  void _showOptionsBottomSheet(
    BuildContext context,
    int index,
    Map<String, dynamic> produk,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  "Edit Produk",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF364153),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TambahProdukScreen(
                            produk: produk,
                            index: index,
                            onSave: _editProduk,
                          ),
                    ),
                  ).then((_) {
                    _getProdukFromFirestore();
                  });
                },
              ),
              ListTile(
                title: Text(
                  "Hapus Produk",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF364153),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(context, index);
                },
              ),
              ListTile(
                title: Text(
                  "Batal",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Hapus produk",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF364153),
            ),
          ),
          content: Text(
            "Semua data terkait dengan produk juga akan dihapus. Tindakan ini tidak bisa dibatalkan.",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF364153),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Batal",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF364153),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _hapusProduk(index);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Hapus",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Header background
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
          // Main content
          Column(
            children: [
              SizedBox(height: 40),
              // Header: "Produk"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      "Produk",
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
              // Search Box
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
              // Produk List Container
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 7,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child:
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : _filteredProdukList.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Belum Ada Produk",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF364153),
                                  ),
                                ),
                                Text(
                                  "Pilih 'Tambah Produk' untuk menambahkan\nproduk kamu ke dalam inventori.",
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
                          : ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            itemCount: _filteredProdukList.length,
                            itemBuilder: (context, index) {
                              final produk = _filteredProdukList[index];
                              return Padding(
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
                                        produk['stok'].toString(),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.lightBlue[600],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: Color(0xFF364153),
                                        ),
                                        onPressed: () {
                                          _showOptionsBottomSheet(
                                            context,
                                            index,
                                            produk,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),
            ],
          ),
        ],
      ),
      // Floating Action Button untuk Tambah Produk
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue[400],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahProdukScreen()),
          ).then((value) {
            if (value != null && value is Map<String, dynamic>) {
              _tambahProduk(value);
            }
          });
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
