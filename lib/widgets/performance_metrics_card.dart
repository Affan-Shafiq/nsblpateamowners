import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';

import '../utils/constants.dart';

class PerformanceMetricsCard extends StatelessWidget {
  final String teamId;

  const PerformanceMetricsCard({
    super.key,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        final metrics = financeProvider.getPerformanceMetricsByTeam(teamId);
        
        if (metrics.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No performance data available for this team.'),
            ),
          );
        }

        final latestMetrics = metrics.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Win %',
                    '${(latestMetrics.winPercentage * 100).toStringAsFixed(1)}%',
                    AppColors.success,
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Record',
                    '${latestMetrics.wins}-${latestMetrics.losses}',
                    AppColors.primary,
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Games',
                    latestMetrics.totalGames.toString(),
                    AppColors.accent,
                    Icons.schedule,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Revenue',
                    '\$${(latestMetrics.totalRevenue / 1000000).toStringAsFixed(1)}M',
                    AppColors.success,
                    Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Payroll',
                    '\$${(latestMetrics.payroll / 1000000).toStringAsFixed(1)}M',
                    AppColors.warning,
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'ROI',
                    '${(latestMetrics.roi * 100).toStringAsFixed(1)}%',
                    latestMetrics.roi > 0 ? AppColors.success : AppColors.error,
                    Icons.show_chart,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(color: color),
            ),
            Text(
              title,
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 