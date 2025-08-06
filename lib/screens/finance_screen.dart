import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/finance.dart';
import '../models/team.dart';
import '../utils/constants.dart';

class FinanceScreen extends StatefulWidget {
  final Team? team;

  const FinanceScreen({super.key, this.team});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔍 [DEBUG] FinanceScreen initState - team: ${widget.team?.name}');
      print('🔍 [DEBUG] FinanceScreen initState - team ID: ${widget.team?.id}');
      final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
      if (widget.team != null) {
        print('🔍 [DEBUG] Fetching team-specific data for team ID: ${widget.team!.id}');
        financeProvider.fetchRevenueReports(widget.team!.id);
        financeProvider.fetchPerformanceMetrics(widget.team!.id);
      } else {
        print('🔍 [DEBUG] No team specified, fetching all financial data');
        financeProvider.fetchAllFinancialData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Financial Overview'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
              if (widget.team != null) {
                financeProvider.fetchRevenueReports(widget.team!.id);
                financeProvider.fetchPerformanceMetrics(widget.team!.id);
              } else {
                financeProvider.fetchAllFinancialData();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
          if (widget.team != null) {
            await financeProvider.fetchRevenueReports(widget.team!.id);
            await financeProvider.fetchPerformanceMetrics(widget.team!.id);
          } else {
            await financeProvider.fetchAllFinancialData();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<FinanceProvider>(
                builder: (context, financeProvider, child) {
                  print('🔍 [DEBUG] FinanceScreen Consumer rebuild');
                  print('🔍 [DEBUG] isLoading: ${financeProvider.isLoading}');
                  print('🔍 [DEBUG] error: ${financeProvider.error}');
                  print('🔍 [DEBUG] total revenue reports: ${financeProvider.revenueReports.length}');
                  print('🔍 [DEBUG] total performance metrics: ${financeProvider.performanceMetrics.length}');
                  
                  if (financeProvider.isLoading) {
                    print('🔍 [DEBUG] Showing loading indicator');
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.paddingLarge),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  if (financeProvider.error != null) {
                    print('🔍 [DEBUG] Showing error: ${financeProvider.error}');
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingLarge),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: AppSizes.paddingMedium),
                            Text(
                              'Error loading data',
                              style: AppTextStyles.heading3,
                            ),
                            const SizedBox(height: AppSizes.paddingSmall),
                            Text(
                              financeProvider.error!,
                              style: AppTextStyles.body2,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSizes.paddingMedium),
                            ElevatedButton(
                              onPressed: () {
                                if (widget.team != null) {
                                  financeProvider.fetchRevenueReports(widget.team!.id);
                                  financeProvider.fetchPerformanceMetrics(widget.team!.id);
                                } else {
                                  financeProvider.fetchAllFinancialData();
                                }
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  // Get team-specific data
                  final teamReports = widget.team != null 
                      ? financeProvider.getRevenueReportsByTeam(widget.team!.id)
                      : financeProvider.revenueReports;
                  final teamMetrics = widget.team != null
                      ? financeProvider.getPerformanceMetricsByTeam(widget.team!.id)
                      : financeProvider.performanceMetrics;
                  
                  print('🔍 [DEBUG] Team reports count: ${teamReports.length}');
                  print('🔍 [DEBUG] Team metrics count: ${teamMetrics.length}');
                  print('🔍 [DEBUG] Current team: ${widget.team?.name}');
                  print('🔍 [DEBUG] Current team ID: ${widget.team?.id}');
                  
                  if (teamReports.isEmpty && teamMetrics.isEmpty) {
                    print('🔍 [DEBUG] No data available, showing empty state');
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.paddingLarge),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.attach_money,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: AppSizes.paddingMedium),
                              Text(
                                'No financial data available',
                                style: AppTextStyles.body1,
                              ),
                              SizedBox(height: AppSizes.paddingSmall),
                              Text(
                                'Pull to refresh or check your connection',
                                style: AppTextStyles.caption,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  
                  print('🔍 [DEBUG] Building data display');
                  return Column(
                    children: [
                      // Revenue Summary Cards (only if we have revenue reports)
                      if (teamReports.isNotEmpty) ...[
                        _buildRevenueSummaryCards(teamReports),
                        const SizedBox(height: AppSizes.paddingLarge),
                        
                        // Revenue Breakdown
                        _buildRevenueBreakdown(teamReports),
                        const SizedBox(height: AppSizes.paddingLarge),
                        
                        // Recent Reports
                        _buildRecentReports(teamReports),
                      ],
                      
                      // Performance Metrics (if available)
                      if (teamMetrics.isNotEmpty) ...[
                        if (teamReports.isNotEmpty) const SizedBox(height: AppSizes.paddingLarge),
                        _buildPerformanceMetrics(teamMetrics),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueSummaryCards(List<RevenueReport> reports) {
    if (reports.isEmpty) return const SizedBox.shrink();
    
    final latestReport = reports.reduce((a, b) => 
        a.reportDate.isAfter(b.reportDate) ? a : b);
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Latest Revenue',
            '\$${(latestReport.totalRevenue / 1000000).toStringAsFixed(1)}M',
            '${latestReport.quarterDisplayName} ${latestReport.year}',
            Icons.trending_up,
            AppColors.success,
          ),
        ),
        const SizedBox(width: AppSizes.paddingMedium),
        Expanded(
          child: _buildSummaryCard(
            'Growth',
            '${latestReport.yearOverYearGrowth.toStringAsFixed(1)}%',
            'Year over Year',
            Icons.show_chart,
            latestReport.yearOverYearGrowth >= 0 ? AppColors.success : AppColors.error,
          ),
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

  Widget _buildRevenueBreakdown(List<RevenueReport> reports) {
    if (reports.isEmpty) return const SizedBox.shrink();
    
    final latestReport = reports.reduce((a, b) => 
        a.reportDate.isAfter(b.reportDate) ? a : b);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Breakdown',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            ...latestReport.revenueByType.entries.map((entry) {
              final percentage = (entry.value / latestReport.totalRevenue) * 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        _getRevenueTypeDisplayName(entry.key),
                        style: AppTextStyles.body1,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: AppColors.textSecondary.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '\$${(entry.value / 1000000).toStringAsFixed(1)}M',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReports(List<RevenueReport> reports) {
    if (reports.isEmpty) return const SizedBox.shrink();
    
    final sortedReports = List.from(reports)
      ..sort((a, b) => b.reportDate.compareTo(a.reportDate));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Reports',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            ...sortedReports.take(5).map((report) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    report.quarterDisplayName,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text('${report.quarterDisplayName} ${report.year}'),
                subtitle: Text('Reported on ${_formatDate(report.reportDate)}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${(report.totalRevenue / 1000000).toStringAsFixed(1)}M',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      '${report.yearOverYearGrowth.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: report.yearOverYearGrowth >= 0 ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(List<PerformanceMetrics> metrics) {
    if (metrics.isEmpty) return const SizedBox.shrink();
    
    final latestMetrics = metrics.reduce((a, b) => a.season > b.season ? a : b);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics (${latestMetrics.season})',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Record',
                    '${latestMetrics.wins}-${latestMetrics.losses}',
                    Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Win %',
                    '${latestMetrics.winPercentage.toStringAsFixed(1)}%',
                    Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Revenue',
                    '\$${(latestMetrics.totalRevenue / 1000000).toStringAsFixed(0)}M',
                    Icons.attach_money,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Merchandise',
                    '\$${(latestMetrics.merchandiseRevenue / 1000000).toStringAsFixed(0)}M',
                    Icons.shopping_bag,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Payroll',
                    '\$${(latestMetrics.payroll / 1000000).toStringAsFixed(0)}M',
                    Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'ROI',
                    '${latestMetrics.roi.toStringAsFixed(1)}%',
                    Icons.analytics,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: AppSizes.paddingSmall),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getRevenueTypeDisplayName(RevenueType type) {
    switch (type) {
      case RevenueType.merchandise:
        return 'Merchandise';
      case RevenueType.sponsorship:
        return 'Sponsorship';
      case RevenueType.media:
        return 'Media Rights';
      case RevenueType.other:
        return 'Other';
      default:
        return 'N/A';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
} 