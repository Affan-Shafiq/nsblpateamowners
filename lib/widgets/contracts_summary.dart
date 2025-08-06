import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contract_provider.dart';
import '../models/contract.dart';
import '../utils/constants.dart';

class ContractsSummary extends StatelessWidget {
  final String teamId;

  const ContractsSummary({
    super.key,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ContractProvider>(
      builder: (context, contractProvider, child) {
        final teamContracts = contractProvider.getContractsByTeam(teamId);
        final pendingCount = teamContracts.where((c) => c.status == ContractStatus.pending).length;
        final activeCount = teamContracts.where((c) => c.status == ContractStatus.active).length;
        final expiredCount = teamContracts.where((c) => c.status == ContractStatus.expired).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contracts Overview',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildContractStatCard(
                    'Pending',
                    pendingCount.toString(),
                    AppColors.warning,
                    Icons.pending,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContractStatCard(
                    'Active',
                    activeCount.toString(),
                    AppColors.success,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContractStatCard(
                    'Expired',
                    expiredCount.toString(),
                    AppColors.error,
                    Icons.schedule,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Contracts',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 12),
            if (teamContracts.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No contracts found for this team.'),
                ),
              )
            else
              ...teamContracts.take(3).map((contract) => _buildContractItem(contract)),
          ],
        );
      },
    );
  }

  Widget _buildContractStatCard(String title, String count, Color color, IconData icon) {
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
              count,
              style: AppTextStyles.heading2.copyWith(color: color),
            ),
            Text(
              title,
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractItem(Contract contract) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(contract.status),
          child: Icon(
            _getContractTypeIcon(contract.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          contract.entityName,
          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${contract.typeDisplayName} • ${contract.statusDisplayName}',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
        trailing: Text(
          '\$${(contract.annualValue / 1000).toStringAsFixed(0)}K',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
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
        return AppColors.error;
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
        return Icons.description;
    }
  }
} 