import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/contract_provider.dart';
import '../providers/auth_provider.dart';
import '../models/contract.dart';
import '../models/team.dart';
import '../utils/constants.dart';

class ContractsScreen extends StatefulWidget {
  final Team? team;
  
  const ContractsScreen({super.key, this.team});

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  Map<String, String> _userNames = {};
  ContractStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    print('🔍 [DEBUG] ContractsScreen initState called');
    if (widget.team != null) {
      print('🔍 [DEBUG] Fetching contracts for team: ${widget.team!.name}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ContractProvider>().fetchContracts(widget.team!.id);
      });
    } else {
      print('🔍 [DEBUG] No team specified, fetching all contracts');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ContractProvider>().fetchAllContracts();
      });
    }
  }

  Future<String> _getUserName(String userId) async {
    if (_userNames.containsKey(userId)) {
      return _userNames[userId]!;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        final userName = userDoc.data()?['name'] ?? 'Unknown User';
        _userNames[userId] = userName;
        return userName;
      } else {
        _userNames[userId] = 'Unknown User';
        return 'Unknown User';
      }
    } catch (e) {
      print('❌ [ERROR] Failed to fetch user name for $userId: $e');
      _userNames[userId] = 'Unknown User';
      return 'Unknown User';
    }
  }

  List<Contract> _getFilteredContracts(List<Contract> contracts) {
    if (_selectedStatus == null) {
      return contracts;
    }
    return contracts.where((contract) => contract.status == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ContractProvider>(
        builder: (context, contractProvider, child) {
          print('🔍 [DEBUG] ContractsScreen Consumer rebuild');
          print('🔍 [DEBUG] isLoading: ${contractProvider.isLoading}');
          print('🔍 [DEBUG] error: ${contractProvider.error}');
          
          final allContracts = widget.team != null 
              ? contractProvider.getContractsByTeam(widget.team!.id)
              : contractProvider.contracts;
          
          final contracts = _getFilteredContracts(allContracts);
          
          print('🔍 [DEBUG] total contracts: ${contracts.length}');
          
          if (contractProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (contractProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Text(
                    'Error: ${contractProvider.error}',
                    style: AppTextStyles.body1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.team != null) {
                        contractProvider.fetchContracts(widget.team!.id);
                      } else {
                        contractProvider.fetchAllContracts();
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header with stats
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Active',
                        '${allContracts.where((c) => c.isActive).length}',
                        AppColors.success,
                        ContractStatus.active,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        '${allContracts.where((c) => c.isPending).length}',
                        AppColors.warning,
                        ContractStatus.pending,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    Expanded(
                      child: _buildStatCard(
                        'Expired',
                        '${allContracts.where((c) => c.isExpired).length}',
                        AppColors.error,
                        ContractStatus.expired,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter indicator
              if (_selectedStatus != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                  child: Row(
                    children: [
                      Chip(
                        label: Text('Filtered: ${_getStatusDisplayName(_selectedStatus!)}'),
                        backgroundColor: _getStatusColor(_selectedStatus!).withOpacity(0.2),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _selectedStatus = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),

              // Contracts List
              Expanded(
                child: contracts.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: AppSizes.paddingMedium),
                            Text(
                              'No contracts found',
                              style: AppTextStyles.body1,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        itemCount: contracts.length,
                        itemBuilder: (context, index) {
                          final contract = contracts[index];
                          return _buildContractCard(context, contract, contractProvider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, ContractStatus status) {
    final isSelected = _selectedStatus == status;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedStatus = null; // Deselect if already selected
          } else {
            _selectedStatus = status;
          }
        });
      },
      child: Card(
        color: isSelected ? color.withOpacity(0.2) : null,
        elevation: isSelected ? 4 : 1,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusDisplayName(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending:
        return 'Pending';
      case ContractStatus.active:
        return 'Active';
      case ContractStatus.expired:
        return 'Expired';
      case ContractStatus.terminated:
        return 'Terminated';
    }
  }

  Widget _buildContractCard(BuildContext context, Contract contract, ContractProvider contractProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getContractTypeColor(contract.type),
          child: Icon(
            _getContractTypeIcon(contract.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          contract.entityName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(contract.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                contract.statusDisplayName,
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(contract.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContractDetail('Type', contract.typeDisplayName),
                _buildContractDetail('Annual Value', '\$${(contract.annualValue / 1000000).toStringAsFixed(1)}M'),
                _buildContractDetail('Start Date', _formatDate(contract.startDate)),
                _buildContractDetail('End Date', _formatDate(contract.endDate)),
                _buildContractDetail('Days Remaining', '${contract.daysRemaining} days'),
                if (contract.approvedBy != null)
                  FutureBuilder<String>(
                    future: _getUserName(contract.approvedBy!),
                    builder: (context, snapshot) {
                      return _buildContractDetail(
                        'Approved By', 
                        snapshot.data ?? 'Loading...'
                      );
                    },
                  ),
                
                // Action Buttons
                if (contract.isPending) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _approveContract(context, contract, contractProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                          child: const Text('Approve'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingSmall),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _rejectContract(context, contract, contractProvider),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Terminate button for active contracts
                if (contract.isActive) ...[
                  const SizedBox(height: AppSizes.paddingMedium),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _terminateContract(context, contract, contractProvider),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Terminate Contract'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
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
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _approveContract(BuildContext context, Contract contract, ContractProvider contractProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Contract'),
        content: Text('Are you sure you want to approve the contract with ${contract.entityName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              final currentUserId = authProvider.userId;
              if (currentUserId != null) {
                contractProvider.approveContract(contract.documentId!, currentUserId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contract approved successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error: User not authenticated'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectContract(BuildContext context, Contract contract, ContractProvider contractProvider) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Contract'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: AppSizes.paddingMedium),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                contractProvider.rejectContract(contract.documentId!, reasonController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contract rejected'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _terminateContract(BuildContext context, Contract contract, ContractProvider contractProvider) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminate Contract'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to terminate the contract with ${contract.entityName}?'),
            const SizedBox(height: AppSizes.paddingMedium),
            const Text('Please provide a reason for termination:'),
            const SizedBox(height: AppSizes.paddingMedium),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                contractProvider.rejectContract(contract.documentId!, reasonController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contract terminated'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Terminate'),
          ),
        ],
      ),
    );
  }
} 