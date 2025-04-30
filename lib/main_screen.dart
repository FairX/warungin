// lib/main_screen.dart

import 'package:dashboard_trial/cashier/cashier.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard.dart';
import 'package:dashboard_trial/product/product.dart';
// --- Ensure correct imports ---
import 'features/laporan/screens/laporan_page.dart';
import 'features/laporan/screens/add_transaction_page.dart';
import 'features/laporan/models/transaction.dart'; // Keep this if Transaction type is needed here

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  // --- Key definition (Keep it typed with the public Widget class) ---
  final GlobalKey<LaporanPageState> _laporanPageKey = GlobalKey<LaporanPageState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget? _buildLaporanFab(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.lightBlueAccent,
      foregroundColor: Colors.white,
      tooltip: 'Tambah Transaksi',
      child: const Icon(Icons.add),
      onPressed: () async {
        final newTransaction = await Navigator.push<Transaction?>(
          context,
          MaterialPageRoute(builder: (context) => const AddTransactionPage()),
        );

        if (newTransaction != null) {
          // This call should now work because the key is assigned below
          // It accesses LaporanPageState's public method
          _laporanPageKey.currentState?.handleAddTransactionResult(newTransaction);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          DashboardScreen(),
          ProdukScreen(),
          CashierScreen(),
          // --- ASSIGN THE KEY HERE ---
          LaporanPage(key: _laporanPageKey),
          const Center(child: Text('Menu')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.lightBlue[400],
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Beranda",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Produk"),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: "Kasir",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: "Laporan",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
        ],
      ),
       // Conditionally add the FloatingActionButton
       floatingActionButton: _selectedIndex == 3 // 3 is the index for Laporan
           ? _buildLaporanFab(context)
           : null, // Show nothing if not on Laporan tab
       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}