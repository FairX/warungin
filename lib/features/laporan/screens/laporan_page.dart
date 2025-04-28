// lib/screens/laporan_page.dart

import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import 'add_transaction_page.dart';
import '../screens/grafik_omset_page.dart'; // Import the new chart page
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  // int _selectedIndex = 3;
  bool _isChartViewActive = false; // State to track active view

  final Map<DateTime, List<Transaction>> _groupedTransactions = {};
  final Map<String, bool> _isExpanded = {};

  // Store calculated chart data to avoid recalculating every build
  List<FlSpot> _chartSpots = [];
  double _chartMaxY = 0;
  final List<String> _chartMonthLabels = [];
  double _selectedMonthIncome = 0; // Income for the month shown in summary

  @override
  void initState() {
    super.initState();
    _loadInitialDataAndPrepareChart(); // Load data and prepare chart initially
  }

  void _loadInitialDataAndPrepareChart() {
    _loadInitialData(); // Load transactions
    _prepareChartData(); // Calculate chart data based on loaded transactions
    // Ensure UI updates after calculations
    if (mounted) {
      setState(() {});
    }
  }

  void _loadInitialData() {
    // (Keep your existing _loadInitialData logic to populate _groupedTransactions)
     final now = DateTime.now();
     final today = DateTime(now.year, now.month, now.day);
     final yesterday = today.subtract(const Duration(days: 1));
     // Sample data (replace with actual data fetching/storage)
     final List<Transaction> sampleTransactions = [
       Transaction(
         id: 'income1-${now.millisecondsSinceEpoch}',
         type: TransactionType.income, amount: 22000, date: today, description: 'Penjualan Harian',
         items: [ TransactionItem(name: "Indomie Goreng", quantity: 3, price: 4000), TransactionItem(name: "Aqua 600", quantity: 2, price: 5000),],
       ),
       Transaction(id: 'expense1-${now.millisecondsSinceEpoch+1}', type: TransactionType.expense, amount: 57000, date: yesterday, description: 'Beli stok Indomie'),
       Transaction(id: 'income2-${now.millisecondsSinceEpoch+2}', type: TransactionType.income, amount: 300000, date: yesterday, description: 'Pembayaran Proyek A'),
       // Add more sample data for previous months to see the chart work
       Transaction(id: 'income-prev1', type: TransactionType.income, amount: 250000, date: DateTime(now.year, now.month - 1, 15)),
       Transaction(id: 'income-prev2', type: TransactionType.income, amount: 450000, date: DateTime(now.year, now.month - 2, 10)),
       Transaction(id: 'income-prev3', type: TransactionType.income, amount: 380000, date: DateTime(now.year, now.month - 3, 20)),
       Transaction(id: 'income-prev4', type: TransactionType.income, amount: 520000, date: DateTime(now.year, now.month - 4, 5)),
        Transaction(id: 'income-prev5', type: TransactionType.income, amount: 480000, date: DateTime(now.year, now.month - 5, 12)),
        Transaction(id: 'income-prev6', type: TransactionType.income, amount: 410000, date: DateTime(now.year, now.month - 6, 25)),
        Transaction(id: 'income-prev7', type: TransactionType.income, amount: 550000, date: DateTime(now.year, now.month - 7, 8)),
        Transaction(id: 'income-prev8', type: TransactionType.income, amount: 600000, date: DateTime(now.year, now.month - 8, 18)),
        Transaction(id: 'income-prev9', type: TransactionType.income, amount: 530000, date: DateTime(now.year, now.month - 9, 3)),
        Transaction(id: 'income-prev10', type: TransactionType.income, amount: 650000, date: DateTime(now.year, now.month - 10, 22)),
        Transaction(id: 'income-prev11', type: TransactionType.income, amount: 700000, date: DateTime(now.year, now.month - 11, 11)),

     ];
     _groupTransactionsByDate(sampleTransactions);
     for (var transaction in sampleTransactions) { _isExpanded[transaction.id] = false; }
  }

  void _groupTransactionsByDate(List<Transaction> transactions) {
    // (Keep your existing _groupTransactionsByDate logic)
    _groupedTransactions.clear();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    for (var transaction in transactions) {
      final dateKey = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      if (!_groupedTransactions.containsKey(dateKey)) { _groupedTransactions[dateKey] = []; }
      _groupedTransactions[dateKey]!.add(transaction);
    }
  }

  // --- New Function to Calculate Chart Data ---
  void _prepareChartData() {
    final allIncomeTransactions = _groupedTransactions.values
        .expand((list) => list)
        .where((t) => t.type == TransactionType.income)
        .toList();

    final Map<int, double> monthlyTotals = {};
    final now = DateTime.now();
    double maxIncome = 0;
    _chartMonthLabels.clear();
    final List<FlSpot> spots = [];
    final monthFormat = DateFormat('MMM', 'id_ID'); // Indonesian month abbreviations

    // Calculate income for the last 12 months (index 0 = 11 months ago, index 11 = current month)
    for (int i = 0; i < 12; i++) {
      // Calculate the target month and year
      DateTime targetDate = DateTime(now.year, now.month - (11 - i), 1); // Start from 11 months ago
      int targetMonth = targetDate.month;
      int targetYear = targetDate.year;

      double total = allIncomeTransactions
          .where((t) => t.date.month == targetMonth && t.date.year == targetYear)
          .fold(0.0, (sum, item) => sum + item.amount);

      monthlyTotals[i] = total;
      spots.add(FlSpot(i.toDouble(), total)); // X=index (0-11), Y=total income
      _chartMonthLabels.add(monthFormat.format(targetDate)); // Add month label

      if (total > maxIncome) {
        maxIncome = total;
      }

       // Store income for the currently selected month (index 11) for the summary card
       if (i == 11) {
          _selectedMonthIncome = total;
       }
    }

    _chartSpots = spots;
    // Set maxY slightly higher than the max income found, handle case where maxIncome is 0
    _chartMaxY = maxIncome == 0 ? 50000 : maxIncome; // Default max Y if no income
  }
  // --- End Chart Data Calculation ---


  void _addTransaction(Transaction newTransaction) {
    setState(() {
      final List<Transaction> allTransactions = _groupedTransactions.values.expand((list) => list).toList();
      allTransactions.add(newTransaction);
      _groupTransactionsByDate(allTransactions);
      _isExpanded[newTransaction.id] = false;
      _prepareChartData(); // Recalculate chart data after adding transaction
    });
  }

  void _toggleExpansion(String transactionId) {
    setState(() {
      _isExpanded[transactionId] = !(_isExpanded[transactionId] ?? false);
    });
  }

  // --- Function to switch views ---
  void _setView(bool isChart) {
    if (_isChartViewActive != isChart) {
      setState(() {
        _isChartViewActive = isChart;
      });
    }
  }

  // --- Helpers for summaries (not strictly needed if chart page uses its own) ---
   double get _totalIncomeThisMonth {
     // This could be simplified now using _selectedMonthIncome if the "Maret" button
     // is only ever for the *current* month when _isChartViewActive is false.
     // If "Maret" can select other months later, keep the original logic.
     if (_isChartViewActive) return _selectedMonthIncome;

     // Original calculation for list view (current month)
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;
     return _groupedTransactions.values
         .expand((list) => list)
         .where((t) => t.type == TransactionType.income && t.date.month == currentMonth && t.date.year == currentYear)
         .fold(0.0, (sum, item) => sum + item.amount);
   }

   double get _totalExpenseThisMonth {
     // Expense summary might only be relevant for the list view
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;
     return _groupedTransactions.values
         .expand((list) => list)
         .where((t) => t.type == TransactionType.expense && t.date.month == currentMonth && t.date.year == currentYear)
         .fold(0.0, (sum, item) => sum + item.amount);
   }
  // ---

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: SafeArea(
    //     child: Column(
    //       children: [
    //         _buildHeader(context), // Header is always visible
    //         Expanded(
    //           // Conditionally display chart or list view
    //           child: _isChartViewActive
    //               ? GrafikOmsetPage(
    //                   totalIncomeForMonth: _selectedMonthIncome, // Pass current month's income
    //                   monthlyIncomeSpots: _chartSpots,
    //                   maxYValue: _chartMaxY,
    //                   monthLabels: _chartMonthLabels,
    //                 )
    //               : _buildListViewContent(context), // Existing list view
    //         ),
    //       ],
    //     ),
    //   ),
    //   bottomNavigationBar: _buildBottomNavigationBar(context),
    //   floatingActionButton: _buildFloatingActionButton(context),
    //   floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    // );
    return SafeArea( // Keep SafeArea if you want padding from OS elements
      child: Column(
        children: [
          _buildHeader(context), // Your existing header for this page
          Expanded(
            // Conditionally display chart or list view
            child: _isChartViewActive
                ? GrafikOmsetPage(
                    totalIncomeForMonth: _selectedMonthIncome,
                    monthlyIncomeSpots: _chartSpots,
                    maxYValue: _chartMaxY,
                    monthLabels: _chartMonthLabels,
                  )
                : _buildListViewContent(context), // Existing list view content
          ),
        ],
      ),
    );
  }

  // Renamed original content builder for clarity
  Widget _buildListViewContent(BuildContext context) {
     return RefreshIndicator(
       onRefresh: () async {
         await Future.delayed(const Duration(seconds: 1));
         _loadInitialDataAndPrepareChart(); // Reload all data
       },
       child: SingleChildScrollView(
         physics: const AlwaysScrollableScrollPhysics(),
         padding: const EdgeInsets.all(16),
         child: Column(
           children: [
              // Only show expense summary in list view
             _buildListSummaryCards(context),
             const SizedBox(height: 20),
             _buildTransactionList(context),
             const SizedBox(height: 70),
           ],
         ),
       ),
     );
   }

   // Extracted Summary cards specifically for the List View
   Widget _buildListSummaryCards(BuildContext context) {
     final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
     return Row(
       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
       children: [
         SummaryCard(
             title: "Pemasukkan",
             value: currencyFormat.format(_totalIncomeThisMonth),
             isIncome: true),
         SummaryCard(
             title: "Pengeluaran",
             value: currencyFormat.format(_totalExpenseThisMonth),
             isIncome: false),
       ],
     );
   }


  // --- Updated Header with Opacity Logic ---
  Widget _buildHeader(BuildContext context) {
    // Define opacities based on the active view
    final double laporanOpacity = _isChartViewActive ? 0.7 : 1.0;
    final double bulananOpacity = _isChartViewActive ? 1.0 : 0.4;
    final double maretOpacity = _isChartViewActive ? 0.4 : 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.lightBlueAccent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12), // Slightly more rounded
          bottomRight: Radius.circular(12),
        ),
         boxShadow: [ BoxShadow( color: Colors.black26, blurRadius: 5, offset: Offset(0, 2), ) ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Group "Laporan" and "Bulanan" text buttons
          Row(
            children: [
              InkWell(
                onTap: () => _setView(false), // Switch to List view
                child: Opacity(
                  opacity: laporanOpacity,
                  child: const Text(
                    "Laporan",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container( // Divider line
                height: 24,
                width: 1.5,
                color: Colors.white.withOpacity(0.5),
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
              InkWell(
                onTap: () => _setView(true), // Switch to Chart view
                child: Opacity(
                  opacity: bulananOpacity,
                  child: const Text(
                    "Bulanan",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Month Selector Button (Maret)
          Opacity(
            opacity: maretOpacity,
            child: InkWell(
               onTap: () {
                 // TODO: Implement month selection logic later
                 // For now, maybe just switch back to list view if tapped?
                 if(_isChartViewActive) _setView(false);
                 print("Month selector tapped");
               },
               borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  DateFormat('MMMM', 'id_ID').format(DateTime.now()), // Current month
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // --- End Updated Header ---

  Widget _buildTransactionList(BuildContext context) {
     // (Keep existing _buildTransactionList logic - it's only shown in list view)
     if (_groupedTransactions.isEmpty) { return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40.0), child: Text("Belum ada transaksi bulan ini.\nTekan '+' untuk menambah.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)))); }
     List<Widget> listItems = [];
     final sortedDates = _groupedTransactions.keys.toList()..sort((a, b) => b.compareTo(a));
     for (var date in sortedDates) {
       listItems.add( Padding( padding: const EdgeInsets.only(top: 16.0, bottom: 8.0), child: Text( DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date), style: const TextStyle( color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w600, ), ), ), );
       listItems.addAll( _groupedTransactions[date]!.map((transaction) { return TransactionCard( transaction: transaction, isExpanded: _isExpanded[transaction.id] ?? false, onToggleExpansion: () => _toggleExpansion(transaction.id), ); }).toList(), );
       listItems.add(const SizedBox(height: 8));
     }
     return Column( crossAxisAlignment: CrossAxisAlignment.start, children: listItems, );
  }

  // Widget _buildBottomNavigationBar(BuildContext context) {
  //   // (Keep existing _buildBottomNavigationBar logic)
  //    return BottomNavigationBar( type: BottomNavigationBarType.fixed, currentIndex: _selectedIndex, onTap: _onItemTapped, items: const [ BottomNavigationBarItem( icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view_rounded), label: "Beranda", ), BottomNavigationBarItem( icon: Icon(Icons.layers_outlined), activeIcon: Icon(Icons.layers), label: "Produk", ), BottomNavigationBarItem( icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: "Kasir", ), BottomNavigationBarItem( icon: Icon(Icons.insert_chart_outlined_rounded), activeIcon: Icon(Icons.insert_chart_rounded), label: "Laporan", ), BottomNavigationBarItem( icon: Icon(Icons.menu_outlined), activeIcon: Icon(Icons.menu), label: "Menu", ), ], );
  // }

  
  // Widget _buildFloatingActionButton(BuildContext context) {
  //    return FloatingActionButton(
  //      backgroundColor: Colors.lightBlueAccent, // Keep FAB color consistent
  //      foregroundColor: Colors.white,
  //      tooltip: 'Tambah Transaksi',
  //      child: const Icon(Icons.add),
  //      onPressed: () async {
  //        final newTransaction = await Navigator.push<Transaction?>(
  //          context,
  //          // --- Navigate to the RENAMED page ---
  //          MaterialPageRoute(builder: (context) => const AddTransactionPage()),
  //        );

  //        if (newTransaction != null && mounted) {
  //          _addTransaction(newTransaction);
  //        }
  //      },
  //    );
  // }
} // End _LaporanPageState