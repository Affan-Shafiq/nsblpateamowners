import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/finance.dart';
import '../utils/constants.dart';

class RevenueChart extends StatelessWidget {
  final String teamId;
  final List<RevenueReport> revenueReports;

  const RevenueChart({
    super.key,
    required this.teamId,
    required this.revenueReports,
  });

  @override
  Widget build(BuildContext context) {
    if (revenueReports.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: AppSizes.paddingSmall),
              Text(
                'No revenue data available',
                style: AppTextStyles.body2,
              ),
            ],
          ),
        ),
      );
    }

    // Sort reports by date
    final sortedReports = List<RevenueReport>.from(revenueReports)
      ..sort((a, b) => a.reportDate.compareTo(b.reportDate));

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quarterly Revenue',
                style: AppTextStyles.heading3,
              ),
              Text(
                'Total: \$${(sortedReports.last.totalRevenue / 1000000).toStringAsFixed(1)}M',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 5000000,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.textSecondary.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppColors.textSecondary.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= 0 && value.toInt() < sortedReports.length) {
                          final report = sortedReports[value.toInt()];
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${report.quarterDisplayName} ${report.year}',
                              style: AppTextStyles.caption,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10000000,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '\$${(value / 1000000).toStringAsFixed(0)}M',
                            style: AppTextStyles.caption,
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
                ),
                minX: 0,
                maxX: (sortedReports.length - 1).toDouble(),
                minY: 0,
                maxY: sortedReports.fold(0.0, (max, report) => 
                    report.totalRevenue > max ? report.totalRevenue : max) * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: sortedReports.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.totalRevenue);
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 