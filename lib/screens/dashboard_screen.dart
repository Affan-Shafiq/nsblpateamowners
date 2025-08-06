import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../providers/finance_provider.dart';
import '../providers/contract_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final teamProvider = context.read<TeamProvider>();
      
      // Fetch user's teams based on their ownership
      teamProvider.fetchUserTeams(authProvider.currentUserModel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Portfolio Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Consumer2<AuthProvider, TeamProvider>(
              builder: (context, authProvider, teamProvider, child) {
                // Get the current user's teamsOwned list
                final user = authProvider.currentUserModel;
                final teamsOwned = user?.teamsOwned ?? [];
                // Get the list of owned teams from TeamProvider
                final ownedTeams = teamProvider.userTeams;
                final totalValue = teamProvider.getTotalPortfolioValue(
                  authProvider.userId ?? '',
                  teamsOwned,
                );
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You own ${ownedTeams.length} team${ownedTeams.length != 1 ? 's' : ''}',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Portfolio Value',
                                '\$${(totalValue / 1000000).toStringAsFixed(1)}M',
                                AppColors.success,
                                Icons.trending_up,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Teams Owned',
                                ownedTeams.length.toString(),
                                AppColors.primary,
                                Icons.sports_soccer,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'View My Teams',
                    Icons.list,
                    AppColors.primary,
                    () => _navigateToTeams(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    'Financial Reports',
                    Icons.assessment,
                    AppColors.success,
                    () => _navigateToReports(context),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Recent Activity
            Text(
              'Recent Activity',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 16),
            Consumer<ContractProvider>(
              builder: (context, contractProvider, child) {
                final pendingContracts = contractProvider.pendingContracts;
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.pending_actions,
                              color: AppColors.warning,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Pending Contracts',
                              style: AppTextStyles.heading3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (pendingContracts.isEmpty)
                          const Text('No pending contracts')
                        else
                          ...pendingContracts.take(3).map((contract) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.warning,
                                child: Icon(
                                  Icons.description,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(contract.entityName),
                              subtitle: Text('${contract.typeDisplayName} Contract'),
                              trailing: Text(
                                '\$${(contract.annualValue / 1000000).toStringAsFixed(1)}M',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Portfolio Performance
            Text(
              'Portfolio Performance',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 16),
            Consumer<FinanceProvider>(
              builder: (context, financeProvider, child) {
                final reports = financeProvider.revenueReports;
                if (reports.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No financial data available'),
                    ),
                  );
                }
                
                final latestReport = reports.reduce((a, b) => 
                    a.reportDate.isAfter(b.reportDate) ? a : b);
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latest Revenue Report',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                'Total Revenue',
                                '\$${(latestReport.totalRevenue / 1000000).toStringAsFixed(1)}M',
                                AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                'Growth',
                                '${latestReport.yearOverYearGrowth.toStringAsFixed(1)}%',
                                latestReport.yearOverYearGrowth >= 0 
                                    ? AppColors.success 
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToTeams(BuildContext context) {
    // Navigate to teams tab
    // This would be handled by the bottom navigation
  }

  void _navigateToReports(BuildContext context) {
    // Navigate to financial reports
    // This would open a detailed reports screen
  }
} 