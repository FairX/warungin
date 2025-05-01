import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showOmsetGraph = true;

  List<double> omsetData = [];
  List<double> profitData = [];
  List<Map<String, dynamic>> hampirHabisProduk = [];
  bool isLoading = true;

  double omsetHariIni = 0;
  double profitHariIni = 0;

  @override
  void initState() {
    super.initState();
    _getOmsetAndProfitData();
    _getProdukHampirHabis();
  }

  // Ambil data omset dan profit dari transaksi
  Future<void> _getOmsetAndProfitData() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot transaksiSnapshot =
          await FirebaseFirestore.instance.collection('transaksi').get();

      List<double> omsetMingguan = List.filled(7, 0.0);
      List<double> profitMingguan = List.filled(7, 0.0);

      double totalOmsetHariIni = 0;
      double totalProfitHariIni = 0;
      DateTime today = DateTime.now();

      for (var doc in transaksiSnapshot.docs) {
        var transaksi = doc.data() as Map<String, dynamic>;
        double nominal = (transaksi['nominal'] ?? 0).toDouble();
        double profit = (transaksi['profit'] ?? 0).toDouble();
        Timestamp ts = transaksi['tanggal'];
        DateTime tgl = ts.toDate();

        // Hari ini
        if (tgl.year == today.year &&
            tgl.month == today.month &&
            tgl.day == today.day) {
          totalOmsetHariIni += nominal;
          totalProfitHariIni += profit;
        }

        // Hari dalam minggu (1=Senin, ..., 7=Minggu)
        int weekdayIndex = tgl.weekday - 1; // jadi 0=Senin ... 6=Minggu
        if (weekdayIndex >= 0 && weekdayIndex < 7) {
          omsetMingguan[weekdayIndex] += nominal;
          profitMingguan[weekdayIndex] += profit;
        }
      }

      setState(() {
        omsetData = omsetMingguan;
        profitData = profitMingguan;
        omsetHariIni = totalOmsetHariIni;
        profitHariIni = totalProfitHariIni;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching omset/profit data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getProdukHampirHabis() async {
    try {
      QuerySnapshot produkSnapshot =
          await FirebaseFirestore.instance.collection('produk').get();

      List<Map<String, dynamic>> hampirHabis = [];

      for (var doc in produkSnapshot.docs) {
        var produk = doc.data() as Map<String, dynamic>;
        int stok = produk['stok'] ?? 0;
        int minimumStok = produk['minimum_stok'] ?? 0;

        if (stok <= minimumStok) {
          hampirHabis.add({'nama': produk['nama'], 'stok': stok.toString()});
        }
      }

      setState(() {
        hampirHabisProduk = hampirHabis;
      });
    } catch (e) {
      print("Error fetching hampir habis produk: $e");
    }
  }

  // ambil data untuk grafik mingguan
  LineChartData _buildChartData(List<double> data) {
    if (data.isEmpty) {
      return LineChartData(gridData: FlGridData(show: true), lineBarsData: []);
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 100000,
        getDrawingHorizontalLine:
            (value) => FlLine(color: Color(0xFFCCCCCC), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              const labels = {
                0: '0k',
                100000: '100k',
                200000: '200k',
                300000: '300k',
                400000: '400k',
                500000: '500k',
              };
              return Text(
                labels[value.toInt()] ?? '',
                style: TextStyle(fontSize: 8, color: Color(0xFF6A7282)),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
              if (value.toInt() < labels.length) {
                return Text(
                  labels[value.toInt()],
                  style: TextStyle(fontSize: 10, color: Color(0xFF6A7282)),
                );
              }
              return Text('');
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY:
          data.reduce((value, element) => value > element ? value : element) *
          1.2,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: Color(0xFF0E9CFF),
          barWidth: 2,
          belowBarData: BarAreaData(
            show: true,
            color: Color(0xFF0E9CFF).withOpacity(0.2),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter:
                (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 3,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Color(0xFF0E9CFF),
                ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, Toko Maju!",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 20),
            _buildSalesCard(),
            SizedBox(height: 20),
            _buildStockCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesCard() {
    return Container(
      width: double.infinity,
      decoration: _boxDecoration(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hari Ini", style: _sectionTitleStyle()),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildToggleBox("Omset", "Rp$omsetHariIni", true),
              _buildToggleBox("Profit", "Rp$profitHariIni", false),
            ],
          ),
          SizedBox(height: 20),
          Text("Minggu Ini", style: _sectionTitleStyle()),
          SizedBox(height: 16),
          SizedBox(
            height: 214,
            child: LineChart(
              _buildChartData(_showOmsetGraph ? omsetData : profitData),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBox(String label, String value, bool isOmset) {
    final selected = _showOmsetGraph == isOmset;
    return GestureDetector(
      onTap: () => setState(() => _showOmsetGraph = isOmset),
      child: Container(
        width: 150,
        height: 57,
        decoration: BoxDecoration(
          color: selected ? Colors.lightBlue[400] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.lightBlue, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: selected ? Colors.white : Color(0xFF4A5565),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: selected ? Colors.white : Color(0xFF364153),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard() {
    return Container(
      width: double.infinity,
      decoration: _boxDecoration(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hampir Habis", style: _sectionTitleStyle()),
          SizedBox(height: 16),
          ...hampirHabisProduk.isEmpty
              ? [Text("Tidak ada produk yang hampir habis")]
              : hampirHabisProduk.map((produk) {
                return _buildStockItem(produk['nama'], produk['stok']);
              }).toList(),
        ],
      ),
    );
  }

  Widget _buildStockItem(String name, String stock) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
          Text(
            stock,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  TextStyle _sectionTitleStyle() => GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Colors.grey[700],
  );

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 7),
    ],
  );
}
