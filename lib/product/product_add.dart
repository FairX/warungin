import 'package:dashboard_trial/service/product_service.dart';
import 'package:dashboard_trial/service/transaction_service.dart'; 
import 'package:dashboard_trial/features/laporan/models/transaction.dart' as laporan;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TambahProdukScreen extends StatefulWidget {
  final Map<String, dynamic>? produk;
  final int? index;
  final Function(int, Map<String, dynamic>)? onSave;

  const TambahProdukScreen({super.key, this.produk, this.index, this.onSave});

  @override
  _TambahProdukScreenState createState() => _TambahProdukScreenState();
}

class _TambahProdukScreenState extends State<TambahProdukScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kodeProdukController = TextEditingController();
  final _namaProdukController = TextEditingController();
  final _hargaBeliController = TextEditingController();
  final _hargaJualController = TextEditingController();
  final _stokController = TextEditingController();
  final _minimumStokController = TextEditingController();
  final ProductService _productService = ProductService();
  final TransactionService _transactionService = TransactionService();

  bool isEdit = false;
  String? documentId;

  @override
  void initState() {
    super.initState();
    if (widget.produk != null) {
      isEdit = true;
      documentId = widget.produk!['id'];

      _kodeProdukController.text = widget.produk!['kode'];
      _namaProdukController.text = widget.produk!['nama'];
      _hargaBeliController.text = widget.produk!['harga_beli'].toString();
      _hargaJualController.text = widget.produk!['harga_jual'].toString();
      _stokController.text = widget.produk!['stok'].toString();
      _minimumStokController.text = widget.produk!['minimum_stok'].toString();
    }
  }

  @override
  void dispose() {
    _kodeProdukController.dispose();
    _namaProdukController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    _stokController.dispose();
    _minimumStokController.dispose();
    super.dispose();
  }

  void _simpanProduk() async {
    if (_formKey.currentState!.validate()) {
      final String namaProduk = _namaProdukController.text;
      final int? hargaBeliInt = int.tryParse(_hargaBeliController.text);
      final int? hargaJualInt = int.tryParse(_hargaJualController.text);
      final int? stokInt = int.tryParse(_stokController.text);
      final int? minimumStokInt = int.tryParse(_minimumStokController.text);

      if (hargaBeliInt == null || hargaJualInt == null || stokInt == null || minimumStokInt == null) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Pastikan semua harga dan stok adalah angka valid.')),
         );
         return;
      }
      final double hargaBeliPerItemDouble = hargaBeliInt.toDouble();

      final produkData = {
        'kode': _kodeProdukController.text,
        'nama': namaProduk,
        'harga_beli': hargaBeliInt,
        'harga_jual': hargaJualInt,
        'stok': stokInt,
        'minimum_stok': minimumStokInt,
      };

      final int quantityPurchased = stokInt;

      try {
        if (isEdit && documentId != null) {
          await _productService.updateProduct(documentId!, produkData);
        } else {
          await _productService.addProduct(produkData);
        }

        if (hargaBeliPerItemDouble > 0 && quantityPurchased > 0) {
           // --- CALCULATE TOTAL EXPENSE ---
           final double totalExpenseAmount = hargaBeliPerItemDouble * quantityPurchased;

           // --- CREATE MORE INFORMATIVE DESCRIPTION ---
           final String expenseDescription = isEdit
               ? 'Update Stok: $namaProduk ($quantityPurchased item)' // Adjust description if needed for edits
               : 'Pembelian Stok: $namaProduk ($quantityPurchased item)';

           final expenseTransaction = laporan.Transaction(
              id: DateTime.now().millisecondsSinceEpoch.toString() + '_prod',
              type: laporan.TransactionType.expense,
              amount: totalExpenseAmount,      // <<< Use the TOTAL calculated amount
              date: DateTime.now(),
              description: expenseDescription, // <<< Use the description with quantity
              items: null, // No items needed for this expense type
           );
           try {
              await _transactionService.addTransaction(expenseTransaction);
              print('Expense transaction saved successfully!');
              // Show combined success message
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Produk berhasil disimpan & laporan diperbarui!')),
               );
           } catch (e) {
              print('Error saving expense transaction: $e');
              // Show specific error for transaction failure
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Produk disimpan, tapi gagal update laporan: $e')),
               );
           }
        } else {
           // If no cost or quantity, just confirm product save
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(isEdit ? 'Produk berhasil diperbarui!' : 'Produk berhasil ditambahkan!')),
           );
        }

        if(mounted) Navigator.pop(context); // Pop only after all operations attempt
        
      } catch (e) {
        print('Error saving product: $e');
        if(mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal menyimpan produk: $e')));
        }
      }
    }
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
          isEdit ? "Edit Produk" : "Tambah Produk",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.grey[800],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kode Produk
                TextFormField(
                  controller: _kodeProdukController,
                  decoration: InputDecoration(
                    labelText: "Kode Produk",
                    hintText: "Masukkan kode produk",
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF99A1AF),
                    ),
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Kode produk tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Nama Produk
                TextFormField(
                  controller: _namaProdukController,
                  decoration: InputDecoration(
                    labelText: "Nama Produk",
                    hintText: "Masukkan nama produk",
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF99A1AF),
                    ),
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Nama produk tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                // Harga Section
                Text(
                  "Harga",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                // Harga Beli
                TextFormField(
                  controller: _hargaBeliController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Harga Beli",
                    hintText: "Masukkan harga beli",
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF99A1AF),
                    ),
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Harga beli tidak boleh kosong";
                    }
                    if (int.tryParse(value) == null) {
                      return "Harga beli harus berupa angka";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Harga Jual
                TextFormField(
                  controller: _hargaJualController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Harga Jual",
                    hintText: "Masukkan harga jual",
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF99A1AF),
                    ),
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Harga jual tidak boleh kosong";
                    }
                    if (int.tryParse(value) == null) {
                      return "Harga jual harus berupa angka";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                // Kuantitas Section
                Text(
                  "Kuantitas",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                // Stok
                TextFormField(
                  controller: _stokController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Stok",
                    hintText: "Masukkan stok",
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF99A1AF),
                    ),
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Stok tidak boleh kosong";
                    }
                    if (int.tryParse(value) == null) {
                      return "Stok harus berupa angka";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Minimum Stok
                TextFormField(
                  controller: _minimumStokController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Minimum Stok",
                    hintText: "Masukkan minimum stok",
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF99A1AF),
                    ),
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Minimum stok tidak boleh kosong";
                    }
                    if (int.tryParse(value) == null) {
                      return "Minimum stok harus berupa angka";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                // Simpan Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _simpanProduk,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[400],
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      "Simpan",
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
          ),
        ),
      ),
    );
  }
}
