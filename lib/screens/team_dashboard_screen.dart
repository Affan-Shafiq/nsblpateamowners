import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../models/contract.dart';
import '../providers/team_provider.dart';
import '../providers/contract_provider.dart';
import '../providers/finance_provider.dart';
import '../utils/constants.dart';
import '../widgets/ownership_summary_card.dart';
import '../widgets/revenue_chart.dart';

import 'contracts_screen.dart';
import 'finance_screen.dart';
import 'performance_screen.dart';
import 'communication_screen.dart';
import 'compliance_screen.dart';

class TeamDashboardScreen extends StatefulWidget {
  final Team team;

  const TeamDashboardScreen({super.key, required this.team});

  @override
  State<TeamDashboardScreen> createState() => _TeamDashboardScreenState();
}

class _TeamDashboardScreenState extends State<TeamDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadTeamData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTeamData() {
    // Use Future.microtask to avoid setState during build
    Future.microtask(() {
      print('🔍 [DEBUG] TeamDashboard _loadTeamData called');
      print('🔍 [DEBUG] Team name: ${widget.team.name}');
      print('🔍 [DEBUG] Team ID: ${widget.team.id}');
      print('🔍 [DEBUG] Team city: ${widget.team.city}');
      
      final contractProvider = context.read<ContractProvider>();
      final financeProvider = context.read<FinanceProvider>();
      
      // Use team ID as identifier for Firebase queries
      print('🔍 [DEBUG] Fetching contracts for team ID: ${widget.team.id}');
      contractProvider.fetchContracts(widget.team.id);
      
      print('🔍 [DEBUG] Fetching revenue reports for team ID: ${widget.team.id}');
      financeProvider.fetchRevenueReports(widget.team.id);
      
      print('🔍 [DEBUG] Fetching performance metrics for team ID: ${widget.team.id}');
      financeProvider.fetchPerformanceMetrics(widget.team.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.team.fullName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
                                  'Founded ${widget.team.foundedYear}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<TeamProvider>().clearSelectedTeam();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showShareOwnershipDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Ownership Summary Card
          OwnershipSummaryCard(team: widget.team),
          
          // Tab Bar
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
                Tab(icon: Icon(Icons.attach_money), text: 'Finance'),
                Tab(icon: Icon(Icons.description), text: 'Contracts'),
                Tab(icon: Icon(Icons.analytics), text: 'Performance'),
                Tab(icon: Icon(Icons.more_horiz), text: 'More'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildFinanceTab(),
                _buildContractsTab(),
                _buildPerformanceTab(),
                _buildMoreTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  'Market Value',
                  '\$${(widget.team.marketValue / 1000000).toStringAsFixed(1)}M',
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                                 child: _buildQuickStatCard(
                   'Founded',
                   '${widget.team.foundedYear}',
                   Icons.history,
                   AppColors.primary,
                 ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingMedium),
          
          Row(
            children: [
                             Expanded(
                 child: _buildQuickStatCard(
                   'Market Value',
                   '\$${(widget.team.marketValue / 1000000).toStringAsFixed(1)}M',
                   Icons.account_balance_wallet,
                   AppColors.accent,
                 ),
               ),
              const SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: Consumer<ContractProvider>(
                  builder: (context, contractProvider, child) {
                                       return _buildQuickStatCard(
                     'Pending Contracts',
                     '${contractProvider.getPendingContractsCount(widget.team.id)}',
                     Icons.pending_actions,
                     AppColors.warning,
                   );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingLarge),
          
          // Revenue Chart
          const Text(
            'Revenue Trend',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          SizedBox(
            height: 200,
            child: Consumer<FinanceProvider>(
              builder: (context, financeProvider, child) {
                if (financeProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                                 return RevenueChart(
                   teamId: widget.team.id,
                   revenueReports: financeProvider.getRevenueReportsByTeam(widget.team.id),
                 );
              },
            ),
          ),
          
          const SizedBox(height: AppSizes.paddingLarge),
          
          // Recent Contracts
          const Text(
            'Recent Contracts',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Consumer<ContractProvider>(
            builder: (context, contractProvider, child) {
              if (contractProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
                             final recentContracts = contractProvider
                   .getContractsByTeam(widget.team.id)
                   .take(3)
                   .toList();
              
              if (recentContracts.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.paddingMedium),
                    child: Text('No contracts found'),
                  ),
                );
              }
              
              return Column(
                children: recentContracts.map((contract) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getContractTypeColor(contract.type),
                        child: Icon(
                          _getContractTypeIcon(contract.type),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(contract.entityName),
                      subtitle: Text('${contract.typeDisplayName} Contract'),
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
                              color: _getStatusColor(contract.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceTab() {
    return FinanceScreen(team: widget.team);
  }

  Widget _buildContractsTab() {
    return ContractsScreen(team: widget.team);
  }

  Widget _buildPerformanceTab() {
    return PerformanceScreen(team: widget.team);
  }

  Widget _buildMoreTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        children: [
          _buildMenuCard(
            'Communication',
            'Send team memos and investor updates',
            Icons.message,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunicationScreen(team: widget.team),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildMenuCard(
            'Compliance & Documents',
            'View important documents and deadlines',
            Icons.folder,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ComplianceScreen(team: widget.team),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildQuickStatCard(String title, String value, IconData icon, Color color) {
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Color _getContractTypeColor(ContractType type) {
    switch (type) {
      case ContractType.player:
        return AppColors.primary;
      case ContractType.coach:
        return AppColors.accent;
      case ContractType.vendor:
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getContractTypeIcon(ContractType type) {
    switch (type) {
      case ContractType.player:
        return Icons.person;
      case ContractType.coach:
        return Icons.sports;
      case ContractType.vendor:
        return Icons.business;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending:
        return AppColors.warning;
      case ContractStatus.active:
        return AppColors.success;
      case ContractStatus.expired:
        return AppColors.error;
      case ContractStatus.terminated:
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showShareOwnershipDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Ownership'),
        content: const Text('This feature allows you to share ownership with another verified user.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement share ownership functionality
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showTeamSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Team Settings'),
        content: const Text('Team settings and configuration options will be available here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 