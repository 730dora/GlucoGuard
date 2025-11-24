import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme.dart';

class HistoryChart extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const HistoryChart({super.key, required this.history});

  // Helper to get the color based on risk
  Color _getRiskColor(double prob) {
    if (prob > 0.7) return Colors.redAccent;
    if (prob > 0.4) return AppTheme.violet;
    return AppTheme.mint;
  }

  @override
  Widget build(BuildContext context) {
    // Show a placeholder if there isn't enough data
    if (history.length < 2) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const Text(
          'Run at least 2 predictions to see your evolution.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // 1. Process the data
    // The history is newest-first, so we must reverse it for the chart
    final List<Map<String, dynamic>> reversedHistory = history.reversed.toList();

    // Convert our history data into a list of (x, y) spots
    final List<FlSpot> spots = [];
    for (int i = 0; i < reversedHistory.length; i++) {
      final item = reversedHistory[i];
      final double probability = item['probability'];
      // x: 0, 1, 2... (the prediction number)
      // y: 0.0 to 1.0 (the risk probability)
      spots.add(FlSpot(i.toDouble(), probability));
    }

    // 2. Build the chart
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          // We don't want a grid
          gridData: const FlGridData(show: false),

          // Hide all the titles and labels on the borders
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

            // Bottom (X-axis) titles
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                // This labels the X-axis "P1", "P2", etc.
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text('P${value.toInt() + 1}',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  );
                },
              ),
            ),

            // Left (Y-axis) titles
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                // This labels the Y-axis "0%", "50%", "100%"
                getTitlesWidget: (value, meta) {
                  String text = '';
                  if (value == 0) text = '0%';
                  if (value == 0.5) text = '50%';
                  if (value == 1) text = '100%';
                  return Text(text,
                      style: const TextStyle(color: Colors.grey, fontSize: 12));
                },
              ),
            ),
          ),

          // Set the min/max boundaries of the chart
          minX: 0,
          maxX: (spots.length - 1).toDouble(), // Max x is the last index
          minY: 0, // 0%
          maxY: 1.0, // 100%

          // Hide the outer border
          borderData: FlBorderData(show: false),

          // Line
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true, // Make it a "cute" curvy line
              color: AppTheme.violet, // Use your theme color
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                // This styles the dots on the data points
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: _getRiskColor(spot.y),
                  );
                },
              ),
              // This adds the nice gradient fill *under* the line
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.violet.withOpacity(0.3),
                    AppTheme.violet.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}