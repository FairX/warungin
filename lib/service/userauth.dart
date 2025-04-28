import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // REGISTER
  Future<String?> registerWithEmailPassword(
    String username,
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan username ke Firestore
      await _db.collection('users').doc(result.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Berhasil
    } on FirebaseAuthException catch (e) {
      return e.message; // Error dari Firebase
    } catch (e) {
      return "Terjadi kesalahan, coba lagi.";
    }
  }

  // LOGIN MENGGUNAKAN USERNAME
  Future<String?> loginWithUsernamePassword(
    String username,
    String password,
  ) async {
    try {
      // Cari email berdasarkan username
      final query =
          await _db
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        return "Username tidak ditemukan.";
      }

      final email = query.docs.first['email'];

      // Login pakai email + password
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return null; // Berhasil
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan, coba lagi.";
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // CEK USER LOGIN ATAU TIDAK
  User? get currentUser => _auth.currentUser;
}
