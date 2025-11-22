import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';

class Chart extends StatelessWidget {
  const Chart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Text(
                          days[value.toInt()],
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: weeklyTBData,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[300]!,
                    strokeWidth: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<BarChartGroupData> weeklyTBData = [
  BarChartGroupData(
    x: 0,
    barRods: [BarChartRodData(toY: 3, color: primaryColor, width: 16, borderRadius: BorderRadius.circular(4))],
  ),
  BarChartGroupData(
    x: 1,
    barRods: [BarChartRodData(toY: 4, color: primaryColor, width: 16, borderRadius: BorderRadius.circular(4))],
  ),
  BarChartGroupData(
    x: 2,
    barRods: [BarChartRodData(toY: 2, color: primaryColor, width: 16, borderRadius: BorderRadius.circular(4))],
  ),
  BarChartGroupData(
    x: 3,
    barRods: [BarChartRodData(toY: 5, color: primaryColor, width: 16, borderRadius: BorderRadius.circular(4))],
  ),
  BarChartGroupData(
    x: 4,
    barRods: [BarChartRodData(toY: 6, color: primaryColor, width: 16, borderRadius: BorderRadius.circular(4))],
  ),
  BarChartGroupData(
    x: 5,
    barRods: [BarChartRodData(toY: 4, color: primaryColor, width: 16, borderRadius: BorderRadius.circular(4))],
  ),
  BarChartGroupData(
    x: 6,
    barRods: [BarChartRodData(toY: 3, color: primaryColor, width: 16, borderRadius: BorderRadius.circular(4))],
  ),
];
