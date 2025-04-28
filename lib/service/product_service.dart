import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference _produkCollection = FirebaseFirestore.instance
      .collection('produk');

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      QuerySnapshot snapshot = await _produkCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Tambahkan id supaya bisa edit/hapus
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<void> addProduct(Map<String, dynamic> data) async {
    await _produkCollection.add(data);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _produkCollection.doc(id).update(data);
  }

  Future<void> deleteProduct(String id) async {
    await _produkCollection.doc(id).delete();
  }
}
