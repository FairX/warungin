import 'package:dashboard_trial/service/userauth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';
import 'input_field.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    final authService = AuthService();
    final error = await authService.registerWithEmailPassword(
      username,
      email,
      password,
    );

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      // Berhasil daftar ➔ ke halaman login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 60),
                  // Logo Warungin
                  Image.asset(
                    'assets/logo_warungin.png',
                    width: 125,
                    height: 70,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 33),
                  // Selamat Datang!
                  Text(
                    "Selamat Datang!",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Color(0xFF364153),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Buat akun baru
                  Text(
                    "Buat akun baru",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Color(0xFF6A7282),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Username Input
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 7,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CustomInputField(
                      controller: _usernameController,
                      hintText: "Username",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Username tidak boleh kosong";
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  // Email Input
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 7,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CustomInputField(
                      controller: _emailController,
                      hintText: "Email",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email tidak boleh kosong";
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return "Email tidak valid";
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  // Password Input
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 7,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CustomInputField(
                      controller: _passwordController,
                      hintText: "Kata sandi",
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Kata sandi tidak boleh kosong";
                        }
                        if (value.length < 6) {
                          return "Kata sandi minimal 6 karakter";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 25),
                  // Tombol Daftar
                  SizedBox(
                    width: 150,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00A6F4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Daftar",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  // atau daftar dengan
                  Text(
                    "atau daftar dengan",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF4A5565).withOpacity(0.75),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Ikon Google dan Facebook
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // daftar dengan Facebook
                        },
                        child: Image.asset(
                          'assets/fb.png',
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: 32),
                      GestureDetector(
                        onTap: () {
                          // daftar dengan Google
                        },
                        child: Image.asset(
                          'assets/google.png',
                          width: 25,
                          height: 25,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  // Sudah memiliki akun? Masuk
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sudah memiliki akun? ",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Masuk",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.lightBlue[600],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
