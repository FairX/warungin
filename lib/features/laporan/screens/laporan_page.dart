// lib/features/laporan/screens/laporan_page.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Adjust import paths if your structure is different
import '../models/transaction.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';
import 'grafik_omset_page.dart';
import '../../../service/transaction_service.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  LaporanPageState createState() => LaporanPageState();
}

class LaporanPageState extends State<LaporanPage> {
  bool _isChartViewActive = false; // State to track active view

  final TransactionService _transactionService = TransactionService();
  List<Transaction> _allTransactions = []; // Store fetched transactions

  final Map<DateTime, List<Transaction>> _groupedTransactions = {};
  final Map<String, bool> _isExpanded = {};

  List<FlSpot> _chartSpots = [];
  double _chartMaxY = 0;
  final List<String> _chartMonthLabels = [];
  double _selectedMonthIncome = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   _loadInitialDataAndPrepareChart();
  // }

  // void _loadInitialDataAndPrepareChart() {
  //   _loadInitialData();
  //   _prepareChartData();
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  // // Loads sample data - replace with actual data fetching
  // void _loadInitialData() {
  //    final now = DateTime.now();
  //    final today = DateTime(now.year, now.month, now.day);
  //    final yesterday = today.subtract(const Duration(days: 1));
  //    final List<Transaction> sampleTransactions = [
  //      Transaction(id: 'income1-${now.millisecondsSinceEpoch}', type: TransactionType.income, amount: 22000, date: today, description: 'Penjualan Harian', items: [ TransactionItem(name: "Indomie Goreng", quantity: 3, price: 4000), TransactionItem(name: "Aqua 600", quantity: 2, price: 5000),]),
  //      Transaction(id: 'expense1-${now.millisecondsSinceEpoch+1}', type: TransactionType.expense, amount: 57000, date: yesterday, description: 'Beli stok Indomie'),
  //      Transaction(id: 'income2-${now.millisecondsSinceEpoch+2}', type: TransactionType.income, amount: 300000, date: yesterday, description: 'Pembayaran Proyek A'),
  //      Transaction(id: 'income-prev1', type: TransactionType.income, amount: 250000, date: DateTime(now.year, now.month - 1, 15)),
  //      Transaction(id: 'income-prev2', type: TransactionType.income, amount: 450000, date: DateTime(now.year, now.month - 2, 10)),
  //      Transaction(id: 'income-prev3', type: TransactionType.income, amount: 380000, date: DateTime(now.year, now.month - 3, 20)),
  //      Transaction(id: 'income-prev4', type: TransactionType.income, amount: 520000, date: DateTime(now.year, now.month - 4, 5)),
  //       Transaction(id: 'income-prev5', type: TransactionType.income, amount: 480000, date: DateTime(now.year, now.month - 5, 12)),
  //       Transaction(id: 'income-prev6', type: TransactionType.income, amount: 410000, date: DateTime(now.year, now.month - 6, 25)),
  //       Transaction(id: 'income-prev7', type: TransactionType.income, amount: 550000, date: DateTime(now.year, now.month - 7, 8)),
  //       Transaction(id: 'income-prev8', type: TransactionType.income, amount: 600000, date: DateTime(now.year, now.month - 8, 18)),
  //       Transaction(id: 'income-prev9', type: TransactionType.income, amount: 530000, date: DateTime(now.year, now.month - 9, 3)),
  //       Transaction(id: 'income-prev10', type: TransactionType.income, amount: 650000, date: DateTime(now.year, now.month - 10, 22)),
  //       Transaction(id: 'income-prev11', type: TransactionType.income, amount: 700000, date: DateTime(now.year, now.month - 11, 11)),
  //    ];
  //    _groupTransactionsByDate(sampleTransactions);
  //    for (var transaction in sampleTransactions) { _isExpanded[transaction.id] = false; }
  // }

  // --- Update grouping, chart prep, and totals to use _allTransactions ---
  void _processTransactions(List<Transaction> transactions) {
    _allTransactions = transactions; // Update the local list
    _groupTransactionsByDate(_allTransactions);
    _prepareChartData(_allTransactions);
  }

  void _groupTransactionsByDate(List<Transaction> transactions) {
    _groupedTransactions.clear();
    for (var transaction in transactions) {
      final dateKey = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      _groupedTransactions.putIfAbsent(dateKey, () => []).add(transaction);
      _isExpanded.putIfAbsent(transaction.id, () => false);
    }
  }

  void _prepareChartData(List<Transaction> transactions) {
    final allIncomeTransactions = transactions
        .where((t) => t.type == TransactionType.income)
        .toList();

    final now = DateTime.now();
    double maxIncome = 0;
    _chartMonthLabels.clear();
    final List<FlSpot> spots = [];
    final monthFormat = DateFormat('MMM', 'id_ID');

    for (int i = 0; i < 12; i++) {
      DateTime targetDate = DateTime(now.year, now.month - (11 - i), 1);
      int targetMonth = targetDate.month;
      int targetYear = targetDate.year;

      double total = allIncomeTransactions
          .where((t) => t.date.month == targetMonth && t.date.year == targetYear)
          .fold(0.0, (sum, item) => sum + item.amount);

      spots.add(FlSpot(i.toDouble(), total));
      _chartMonthLabels.add(monthFormat.format(targetDate));

      if (total > maxIncome) {
        maxIncome = total;
      }
      if (i == 11) {
        _selectedMonthIncome = total; // Income for the current month
      }
    }
    _chartSpots = spots;
    _chartMaxY = maxIncome == 0 ? 50000 : maxIncome;
  }

  // Updates UI state locally
  // void _internalAddTransaction(Transaction newTransaction) {
  //   setState(() {
  //     final List<Transaction> allTransactions = _groupedTransactions.values.expand((list) => list).toList();
  //     allTransactions.add(newTransaction);
  //     _groupTransactionsByDate(allTransactions);
  //     _isExpanded[newTransaction.id] = false;
  //     _prepareChartData(allTransactions);
  //   });
  // }

  // PUBLIC Method called via GlobalKey from MainScreen
  void handleAddTransactionResult(Transaction newTransaction) {
     _internalAddTransaction(newTransaction);
     // TODO: Add call to service layer here to SAVE the transaction persistently
     print("Transaction received in LaporanPage: ${newTransaction.type} - ${newTransaction.amount}");
   }

  // void _toggleExpansion(String transactionId) {
  //   setState(() {
  //        _internalAddTransaction(newTransaction);
  //    });
  //    // TODO: Call service layer to SAVE the transaction persistently
  //    print("Transaction received in LaporanPage: ${newTransaction.type} - ${newTransaction.amount}");
  // }

  void _internalAddTransaction(Transaction newTransaction) {
      // This just updates the local list instantly for UI feedback,
      // StreamBuilder will update again when data arrives from backend.
      // Alternatively, remove this and rely purely on the stream update.
      _allTransactions.insert(0, newTransaction); // Add to beginning
      _groupTransactionsByDate(_allTransactions);
      _isExpanded[newTransaction.id] = false;
      _prepareChartData(_allTransactions);
   }

  void _setView(bool isChart) {
    if (_isChartViewActive != isChart) {
      setState(() {
        _isChartViewActive = isChart;
      });
    }
  }

  void _toggleExpansion(String transactionId) {
    // This is fine - called by user interaction (InkWell onTap)
    setState(() {
      _isExpanded[transactionId] = !(_isExpanded[transactionId] ?? false);
    });
  }

   double get _totalIncomeThisMonth {
     // This getter now calculates based on the *currently displayed* data
     // which comes from the stream/fetched data.
     if (_isChartViewActive) return _selectedMonthIncome;
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;
     return _allTransactions // Use the fetched list
         .where((t) => t.type == TransactionType.income && t.date.month == currentMonth && t.date.year == currentYear)
         .fold(0.0, (sum, item) => sum + item.amount);
   }

   double get _totalExpenseThisMonth {
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;
     return _groupedTransactions.values
         .expand((list) => list)
         .where((t) => t.type == TransactionType.expense && t.date.month == currentMonth && t.date.year == currentYear)
         .fold(0.0, (sum, item) => sum + item.amount);
   }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: StreamBuilder<List<Transaction>>(
              stream: _transactionService.getTransactionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print("Error fetching transactions: ${snapshot.error}");
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Use empty list if no data, avoid null errors
                final transactions = snapshot.data ?? [];

                // --- Process data WITHOUT calling setState ---
                _processTransactions(transactions);

                // Build UI using the processed data stored in state variables
                return _buildMainContentArea(transactions);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper widget to build the main content area ---
  Widget _buildMainContentArea(List<Transaction> transactions) {
     return _isChartViewActive
         ? GrafikOmsetPage(
             totalIncomeForMonth: _selectedMonthIncome,
             monthlyIncomeSpots: _chartSpots,
             maxYValue: _chartMaxY,
             monthLabels: _chartMonthLabels,
           )
         : _buildListViewContent(context, transactions); // Pass transactions
   }


  // Modify to accept transactions list
  Widget _buildListViewContent(BuildContext context, List<Transaction> transactions) {
     // RefreshIndicator might not be needed with StreamBuilder,
     // but keep if you want manual refresh for other reasons.
     return RefreshIndicator(
       onRefresh: () async {
         // Refresh logic might change - maybe refetch explicitly if needed
         // For now, StreamBuilder handles updates automatically.
         await Future.delayed(const Duration(seconds: 1));
       },
       child: SingleChildScrollView(
         physics: const AlwaysScrollableScrollPhysics(),
         padding: const EdgeInsets.all(16),
         child: Column(
           children: [
             _buildListSummaryCards(context), // Uses getters based on _allTransactions
             const SizedBox(height: 20),
             _buildTransactionList(context, transactions), // Pass transactions
             const SizedBox(height: 70),
           ],
         ),
       ),
     );
   }

   Widget _buildTransactionList(BuildContext context, List<Transaction> transactions) {
     // Grouping is now done in _processTransactions
     final grouped = _groupedTransactions; // Use the state variable

     if (grouped.isEmpty) {
        return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40.0), child: Text("Belum ada transaksi.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16))));
     }

     List<Widget> listItems = [];
     // Sort dates for display order
     final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

     for (var date in sortedDates) {
       listItems.add( Padding( padding: const EdgeInsets.only(top: 16.0, bottom: 8.0), child: Text( DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date), style: const TextStyle( color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w600, ), ), ), );
       // Map transactions for the current date
       listItems.addAll( grouped[date]!.map((transaction) {
            return TransactionCard(
                transaction: transaction,
                isExpanded: _isExpanded[transaction.id] ?? false,
                onToggleExpansion: () => _toggleExpansion(transaction.id),
            );
       }).toList(), );
       listItems.add(const SizedBox(height: 8));
     }
     return Column( crossAxisAlignment: CrossAxisAlignment.start, children: listItems, );
  }

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

  Widget _buildHeader(BuildContext context) {
    final double laporanOpacity = _isChartViewActive ? 0.7 : 1.0;
    final double bulananOpacity = _isChartViewActive ? 1.0 : 0.4;
    final double monthSelectorOpacity = _isChartViewActive ? 0.4 : 1.0;

    const double headerHeight = 139.0;
    final BorderRadius headerBorderRadius = BorderRadius.circular(20);
    const double contentTopPadding = 40.0; // Keep top padding

    return Container(
      height: headerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent,
        borderRadius: headerBorderRadius,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        // Adjust padding if necessary, top padding remains important
        padding: const EdgeInsets.only(
          top: contentTopPadding,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Row( // This is the main Row containing the two groups
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // --- CHANGE THIS LINE FOR VERTICAL CENTERING ---
          crossAxisAlignment: CrossAxisAlignment.center, // Changed from .start
          children: [
            // Group "Laporan" and "Bulanan" text buttons
            Row(
              // This inner row's alignment centers Laporan | Bulanan relative to each other
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => _setView(false),
                  child: Opacity(
                    opacity: laporanOpacity,
                    child: const Text(
                      "Laporan",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 24,
                  width: 1.5,
                  color: Colors.white.withOpacity(0.5),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
                InkWell(
                  onTap: () => _setView(true),
                  child: Opacity(
                    opacity: bulananOpacity,
                    child: const Text(
                      "Bulanan",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Month Selector Button (April)
            Opacity(
              opacity: monthSelectorOpacity,
              child: InkWell(
                 onTap: () {
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
                    DateFormat('MMMM', 'id_ID').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500,),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} // End LaporanPageState