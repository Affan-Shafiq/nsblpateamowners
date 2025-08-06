import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../providers/finance_provider.dart';
import '../providers/contract_provider.dart';
import '../providers/auth_provider.dart';
import '../models/contract.dart';
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
      final contractProvider = context.read<ContractProvider>();
      final financeProvider = context.read<FinanceProvider>();
      
             // Fetch all teams and user's teams
       teamProvider.fetchTeams(); // Fetch all teams first
       teamProvider.fetchUserTeams(authProvider.currentUserModel);
      
             // Fetch all contracts and financial data for the user's teams
       if (authProvider.currentUserModel != null) {
         final teamsOwned = authProvider.currentUserModel!.teamsOwned;
         for (final teamOwnership in teamsOwned) {
           final teamId = teamOwnership['teamId'] as String;
           contractProvider.fetchContracts(teamId);
           financeProvider.fetchRevenueReports(teamId);
           financeProvider.fetchPerformanceMetrics(teamId);
         }
       }
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
                                Icons.business,
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
            

            
            // Recent Activity
            Text(
              'Recent Activity',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 16),
            Consumer2<ContractProvider, TeamProvider>(
              builder: (context, contractProvider, teamProvider, child) {
                final allContracts = contractProvider.contracts;
                final userTeams = teamProvider.userTeams;
                
                // Get contracts for user's teams
                final userTeamIds = userTeams.map((team) => team.id).toList();
                final userContracts = allContracts.where((contract) => 
                    userTeamIds.contains(contract.teamId)).toList();
                
                                 // Sort by start date (most recent first)
                 userContracts.sort((a, b) => b.startDate.compareTo(a.startDate));
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.recent_actors,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recent Contracts',
                              style: AppTextStyles.heading3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (userContracts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No contracts found',
                              style: AppTextStyles.body2,
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ...userContracts.take(3).map((contract) {
                            final team = userTeams.firstWhere(
                              (team) => team.id == contract.teamId,
                              orElse: () => userTeams.first,
                            );
                            
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getContractStatusColor(contract.status),
                                child: Icon(
                                  _getContractTypeIcon(contract.type),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(contract.entityName),
                              subtitle: Text('${contract.typeDisplayName} • ${team.name}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${(contract.annualValue / 1000000).toStringAsFixed(1)}M',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  Text(
                                    contract.statusDisplayName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getContractStatusColor(contract.status),
                                      fontWeight: FontWeight.w500,
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
              },
            ),
            
            const SizedBox(height: 24),
            
            // Portfolio Performance
            Text(
              'Portfolio Performance',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 16),
            Consumer2<FinanceProvider, TeamProvider>(
              builder: (context, financeProvider, teamProvider, child) {
                final userTeams = teamProvider.userTeams;
                
                if (userTeams.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No teams found',
                        style: AppTextStyles.body2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                
                // Calculate total portfolio metrics
                double totalRevenue = 0;
                double totalGrowth = 0;
                int reportCount = 0;
                
                for (final team in userTeams) {
                  final teamReports = financeProvider.getRevenueReportsByTeam(team.id);
                  if (teamReports.isNotEmpty) {
                    final latestReport = teamReports.reduce((a, b) => 
                        a.reportDate.isAfter(b.reportDate) ? a : b);
                    totalRevenue += latestReport.totalRevenue;
                    totalGrowth += latestReport.yearOverYearGrowth;
                    reportCount++;
                  }
                }
                
                if (reportCount == 0) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No financial data available',
                        style: AppTextStyles.body2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                
                final averageGrowth = totalGrowth / reportCount;
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portfolio Overview',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                'Total Revenue',
                                '\$${(totalRevenue / 1000000).toStringAsFixed(1)}M',
                                AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                'Avg Growth',
                                '${averageGrowth.toStringAsFixed(1)}%',
                                averageGrowth >= 0 
                                    ? AppColors.success 
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Team Performance',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 8),
                        ...userTeams.map((team) {
                          final teamReports = financeProvider.getRevenueReportsByTeam(team.id);
                          final teamMetrics = financeProvider.getPerformanceMetricsByTeam(team.id);
                          
                          double teamRevenue = 0;
                          if (teamReports.isNotEmpty) {
                            final latestReport = teamReports.reduce((a, b) => 
                                a.reportDate.isAfter(b.reportDate) ? a : b);
                            teamRevenue = latestReport.totalRevenue;
                          }
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: Text(
                                team.name[0],
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(team.name),
                            subtitle: Text('${teamMetrics.length} performance records'),
                            trailing: Text(
                              '\$${(teamRevenue / 1000000).toStringAsFixed(1)}M',
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

  Color _getContractStatusColor(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending:
        return AppColors.warning;
      case ContractStatus.active:
        return AppColors.success;
      case ContractStatus.expired:
        return AppColors.error;
      case ContractStatus.terminated:
        return AppColors.error;
    }
  }

  IconData _getContractTypeIcon(ContractType type) {
    switch (type) {
      case ContractType.player:
        return Icons.person;
      case ContractType.coach:
        return Icons.business;
      case ContractType.vendor:
        return Icons.business;
      default:
        return Icons.help;
    }
  }
} 