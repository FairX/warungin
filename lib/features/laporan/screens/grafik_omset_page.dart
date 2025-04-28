// lib/screens/grafik_omset_page.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/summary_card.dart'; // Reuse the summary card

class GrafikOmsetPage extends StatelessWidget {
  final double totalIncomeForMonth; // Total income for the selected month
  final List<FlSpot> monthlyIncomeSpots; // Data points for the chart (last 12 months)
  final double maxYValue; // Max Y value for the chart axis
  final List<String> monthLabels; // Labels for the X-axis

  const GrafikOmsetPage({
    super.key,
    required this.totalIncomeForMonth,
    required this.monthlyIncomeSpots,
    required this.maxYValue,
    required this.monthLabels,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final incomeUnitFormat = NumberFormat("#,##0", "id_ID"); // For Y-axis labels (e.g., Jt)

    // Determine a reasonable interval for Y-axis labels
    double yInterval = (maxYValue / 5).ceilToDouble(); // Aim for about 5-6 labels
    if (yInterval < 10000) {
      yInterval = 10000; // Minimum interval if amounts are small
    } else if (yInterval < 20000) yInterval = 20000;
     else if (yInterval < 50000) yInterval = 50000;
     else yInterval = (yInterval / 10000).ceil() * 10000; // Round up to nearest 10k, 50k etc.


    return SingleChildScrollView( // Allow scrolling if chart is tall
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Summary Card for the selected month's income
          SummaryCard(
            title: "Pemasukkan", // Or selected month
            value: currencyFormat.format(totalIncomeForMonth),
            isIncome: true,
          ),
          const SizedBox(height: 24),

          // Chart Container
          Container(
            padding: const EdgeInsets.only(top: 16, right: 16, bottom: 8), // Padding for labels
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(8),
               boxShadow: [
                 BoxShadow(
                   color: Colors.grey.withOpacity(0.15),
                   spreadRadius: 1,
                   blurRadius: 3,
                   offset: const Offset(0, 1),
                 ),
               ],
             ),
            height: 300, // Give the chart a fixed height
            child: LineChart(
              LineChartData( // *** START of LineChartData ***
                minX: 0,
                maxX: 11, // 12 months (0 to 11)
                minY: 0,
                maxY: (maxYValue * 1.1).ceilToDouble(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yInterval,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.amber.withOpacity(0.4),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < monthLabels.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8.0,
                            child: Text(
                              monthLabels[index],
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: yInterval,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                          String label;
                           if (value >= 1000000) {
                              label = '${incomeUnitFormat.format(value / 1000000)}Jt';
                           } else if (value >= 1000) {
                              label = '${incomeUnitFormat.format(value / 1000)}rb';
                           }
                            else {
                              label = incomeUnitFormat.format(value);
                           }
                          if (value == meta.min) return Container();
                         return Text(label,
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11),
                              textAlign: TextAlign.left);
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.5),
                     left: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.5),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: monthlyIncomeSpots,
                    isCurved: false,
                    color: Colors.purpleAccent.shade400,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                     tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                     getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                       return touchedBarSpots.map((barSpot) {
                         final flSpot = barSpot;
                         String month = monthLabels[flSpot.x.toInt()];
                         return LineTooltipItem(
                           '$month\n',
                           const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                           children: <TextSpan>[
                             TextSpan(
                               text: currencyFormat.format(flSpot.y),
                               style: TextStyle(
                                 color: Colors.white.withOpacity(0.9),
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                           ],
                         );
                       }).toList();
                     },
                   ),
                 handleBuiltInTouches: true,
                ),
              ),
              // swapAnimationDuration: Duration(milliseconds: 250), // Optional animation
              // swapAnimationCurve: Curves.linear, // Optional animation curve
            ),
          ),
        ],
      ),
    );
  }
}