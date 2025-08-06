import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/team.dart';
import '../models/finance.dart';
import '../utils/constants.dart';

class PerformanceScreen extends StatelessWidget {
  final Team? team;

  const PerformanceScreen({super.key, this.team});

  @override
  Widget build(BuildContext context) {
    print('🔍 [DEBUG] PerformanceScreen build - team: ${team?.name}');
    print('🔍 [DEBUG] PerformanceScreen build - team ID: ${team?.id}');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          print('🔍 [DEBUG] PerformanceScreen Consumer rebuild');
          print('🔍 [DEBUG] isLoading: ${financeProvider.isLoading}');
          print('🔍 [DEBUG] total performance metrics: ${financeProvider.performanceMetrics.length}');
          
          if (financeProvider.isLoading) {
            print('🔍 [DEBUG] Showing loading indicator');
            return const Center(child: CircularProgressIndicator());
          }

          // Get team-specific performance metrics
          final teamMetrics = team != null 
              ? financeProvider.getPerformanceMetricsByTeam(team!.id)
              : financeProvider.performanceMetrics;

          print('🔍 [DEBUG] Team-specific metrics count: ${teamMetrics.length}');
          print('🔍 [DEBUG] Current team: ${team?.name}');
          print('🔍 [DEBUG] Current team ID: ${team?.id}');

          if (teamMetrics.isEmpty) {
            print('🔍 [DEBUG] No performance data available, showing empty state');
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: AppSizes.paddingMedium),
                  Text(
                    'No performance data available',
                    style: AppTextStyles.body1,
                  ),
                ],
              ),
            );
          }

          print('🔍 [DEBUG] Building performance display with ${teamMetrics.length} metrics');
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Team Performance',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                
                // Performance Summary Cards
                _buildPerformanceSummaryCards(teamMetrics),
                const SizedBox(height: AppSizes.paddingLarge),
                
                // Performance Metrics
                _buildPerformanceMetrics(teamMetrics),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerformanceSummaryCards(List<PerformanceMetrics> metrics) {
    final latestMetrics = metrics.reduce((a, b) => a.season > b.season ? a : b);
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Win %',
                '${latestMetrics.winPercentage.toStringAsFixed(1)}%',
                '${latestMetrics.wins}-${latestMetrics.losses}',
                Icons.trending_up,
                AppColors.success,
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: _buildSummaryCard(
                'Games',
                latestMetrics.totalGames.toString(),
                'Total Games',
                Icons.schedule,
                AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Revenue',
                '\$${(latestMetrics.totalRevenue / 1000000).toStringAsFixed(0)}M',
                'Total Revenue',
                Icons.attach_money,
                AppColors.success,
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: _buildSummaryCard(
                'ROI',
                '${latestMetrics.roi.toStringAsFixed(1)}%',
                'Return on Investment',
                Icons.trending_up,
                latestMetrics.roi >= 0 ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(List<PerformanceMetrics> metrics) {
    final latestMetrics = metrics.reduce((a, b) => a.season > b.season ? a : b);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Performance (${latestMetrics.season})',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            
            _buildMetricRow('Total Revenue', '\$${(latestMetrics.totalRevenue / 1000000).toStringAsFixed(1)}M'),
            _buildMetricRow('Merchandise Revenue', '\$${(latestMetrics.merchandiseRevenue / 1000000).toStringAsFixed(1)}M'),
            _buildMetricRow('Payroll', '\$${(latestMetrics.payroll / 1000000).toStringAsFixed(1)}M'),
            _buildMetricRow('Profit Margin', '${latestMetrics.profitMargin.toStringAsFixed(1)}%'),
            
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Revenue vs Payroll Chart
            Container(
              height: 200,
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Revenue vs Payroll',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: (latestMetrics.totalRevenue / 200000000) * 150,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Revenue',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingMedium),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: (latestMetrics.payroll / 200000000) * 150,
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Payroll',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body1),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
} 