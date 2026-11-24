import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/chart_point_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';

class InteractivePriceChart extends StatefulWidget {
  final List<ChartPointEntity> chartPoints;
  final int selectedDays;
  final Function(int days) onTimeframeChanged;
  final bool isLoading;

  const InteractivePriceChart({
    super.key,
    required this.chartPoints,
    required this.selectedDays,
    required this.onTimeframeChanged,
    this.isLoading = false,
  });

  @override
  State<InteractivePriceChart> createState() => _InteractivePriceChartState();
}

class _InteractivePriceChartState extends State<InteractivePriceChart> {
  ChartPointEntity? _touchedPoint;

  @override
  Widget build(BuildContext context) {
    if (widget.chartPoints.isEmpty) {
      return Container(
        height: 240,
        alignment: Alignment.center,
        child: const Text('No chart data available', style: TextStyle(color: AppTheme.textMuted)),
      );
    }

    final firstPrice = widget.chartPoints.first.price;
    final lastPrice = widget.chartPoints.last.price;
    final isGaining = lastPrice >= firstPrice;
    final chartColor = isGaining ? AppTheme.gainGreen : AppTheme.lossRed;

    // Calculate min and max for bounds
    double minPrice = widget.chartPoints.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    double maxPrice = widget.chartPoints.map((e) => e.price).reduce((a, b) => a > b ? a : b);
    if (minPrice == maxPrice) {
      minPrice *= 0.95;
      maxPrice *= 1.05;
    }
    final padding = (maxPrice - minPrice) * 0.1;
    minPrice = (minPrice - padding).clamp(0.0, double.infinity);
    maxPrice += padding;

    final spots = <FlSpot>[];
    for (int i = 0; i < widget.chartPoints.length; i++) {
      spots.add(FlSpot(i.toDouble(), widget.chartPoints[i].price));
    }

    final activePoint = _touchedPoint ?? widget.chartPoints.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Interactive Scrubbing Price Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _touchedPoint != null ? 'Price at Point' : 'Current Rate',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.formatCurrency(activePoint.price),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Date / Time', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d, HH:mm').format(activePoint.timestamp),
                    style: const TextStyle(
                      color: AppTheme.secondaryAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Chart View
        SizedBox(
          height: 220,
          child: widget.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryAccent, strokeWidth: 2),
                )
              : LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (spots.length - 1).toDouble(),
                    minY: minPrice,
                    maxY: maxPrice,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (maxPrice - minPrice) / 4,
                      getDrawingHorizontalLine: (value) => const FlLine(
                        color: AppTheme.dividerColor,
                        strokeWidth: 0.8,
                        dashArray: [4, 4],
                      ),
                    ),
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final point = widget.chartPoints[spot.spotIndex];
                            return LineTooltipItem(
                              '${CurrencyFormatter.formatCurrency(spot.y)}\n${DateFormat('HH:mm').format(point.timestamp)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }).toList();
                        },
                      ),
                      touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                        if (response?.lineBarSpots != null && response!.lineBarSpots!.isNotEmpty) {
                          final index = response.lineBarSpots!.first.spotIndex;
                          if (index < widget.chartPoints.length) {
                            setState(() {
                              _touchedPoint = widget.chartPoints[index];
                            });
                          }
                        } else if (event is FlPanEndEvent || event is FlTapUpEvent) {
                          setState(() {
                            _touchedPoint = null;
                          });
                        }
                      },
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.25,
                        color: chartColor,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              chartColor.withValues(alpha: 0.3),
                              chartColor.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // Timeframe selector buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimeframeChip('24H', 1),
            _buildTimeframeChip('7D', 7),
            _buildTimeframeChip('30D', 30),
            _buildTimeframeChip('1Y', 365),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeframeChip(String label, int days) {
    final isSelected = widget.selectedDays == days;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        if (!isSelected) {
          widget.onTimeframeChanged(days);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryAccent : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryAccent : AppTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
