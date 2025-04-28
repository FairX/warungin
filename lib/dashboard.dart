import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showOmsetGraph = true;

  final List<double> omsetData = [
    112500,
    175000,
    350000,
    700000,
    200000,
    400000,
    60000,
  ];
  final List<double> profitData = [
    50000,
    75000,
    150000,
    300000,
    100000,
    200000,
    30000,
  ];

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
              _buildToggleBox("Omset", "Rp250.000", true),
              _buildToggleBox("Profit", "Rp150.000", false),
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
          ...[
            _buildStockItem("Coca Cola", "sisa 9"),
            _buildStockItem("Sprite", "sisa 8"),
            _buildStockItem("Fanta", "sisa 7"),
            _buildStockItem("Aqua", "sisa 8"),
            _buildStockItem("Le Minerale", "sisa 7"),
          ],
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

  LineChartData _buildChartData(List<double> data) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 175000,
        getDrawingHorizontalLine:
            (value) => FlLine(color: Color(0xFFCCCCCC), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              const labels = {
                0: '1',
                175000: '175k',
                350000: '350k',
                525000: '525k',
                700000: '700k',
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
              if (value.toInt() >= 0 && value.toInt() < labels.length) {
                return Text(
                  labels[value.toInt()],
                  style: TextStyle(fontSize: 8, color: Color(0xFF6A7282)),
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
      maxY: 700000,
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            data.length,
            (index) => FlSpot(index.toDouble(), data[index]),
          ),
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
}
