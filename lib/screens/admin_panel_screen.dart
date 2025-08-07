import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../models/finance.dart';
import '../models/contract.dart';
import '../models/user_model.dart';
import '../models/team.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
      appBar: AppBar(
          title: const Text('Admin Panel'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Add Team'),
              Tab(text: 'Create Contract'),
              Tab(text: 'Revenue Reports'),
              Tab(text: 'Performance Metrics'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AddTeamTab(),
            _CreateContractTab(),
            _AddRevenueReportTab(),
            _AddPerformanceMetricsTab(),
          ],
        ),
      ),
    );
  }

}

class _AddTeamTab extends StatefulWidget {
  const _AddTeamTab();

  @override
  State<_AddTeamTab> createState() => _AddTeamTabState();
}

class _AddTeamTabState extends State<_AddTeamTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _marketValueController = TextEditingController();
  final _foundedYearController = TextEditingController();
  String? _selectedOwnerId;
  double _ownerStake = 100.0;
  List<UserModel> _users = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return FutureBuilder<List<UserModel>>(
          future: adminProvider.getAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading users: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            _users = snapshot.data ?? [];

            return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                      'Add New Team',
              style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 24),
                    
                    // Team Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Team Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter team name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // City
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Market Value
                    TextFormField(
                      controller: _marketValueController,
                      decoration: const InputDecoration(
                        labelText: 'Market Value (\$ millions)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter market value';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Founded Year
                    TextFormField(
                      controller: _foundedYearController,
                      decoration: const InputDecoration(
                        labelText: 'Founded Year',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter founded year';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid year';
                        }
                        final year = int.parse(value);
                        if (year < 1900 || year > DateTime.now().year) {
                          return 'Please enter a valid year between 1900 and ${DateTime.now().year}';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Owner Selection
                    DropdownButtonFormField<String>(
                      value: _selectedOwnerId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Team Owner',
                        border: OutlineInputBorder(),
                      ),
                      items: _users.map((user) {
                        return DropdownMenuItem(
                          value: user.email, // Using email as ID for now
                          child: Text(
                            '${user.name} (${user.email})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedOwnerId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an owner';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Owner Stake
                    TextFormField(
                      initialValue: _ownerStake.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Owner Stake (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _ownerStake = double.tryParse(value) ?? 100.0;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: adminProvider.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  final selectedUser = _users.firstWhere(
                                    (user) => user.email == _selectedOwnerId,
                                  );
                                  
                                                                     final success = await adminProvider.addTeam(
                                     name: _nameController.text,
                                     city: _cityController.text,
                                     marketValue: double.parse(_marketValueController.text),
                                     foundedYear: int.parse(_foundedYearController.text),
                                     ownerEmail: selectedUser.email,
                                     ownerName: selectedUser.name,
                                     ownerStake: _ownerStake,
                                   );
                                  
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Team added successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                                                         _nameController.clear();
                                     _cityController.clear();
                                     _marketValueController.clear();
                                     _foundedYearController.clear();
                                  } else if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(adminProvider.error ?? 'Failed to add team'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: adminProvider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Add Team'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


}

class _CreateContractTab extends StatefulWidget {
  const _CreateContractTab();

  @override
  State<_CreateContractTab> createState() => _CreateContractTabState();
}

class _CreateContractTabState extends State<_CreateContractTab> {
  final _formKey = GlobalKey<FormState>();
  final _entityNameController = TextEditingController();
  final _valueController = TextEditingController();
  ContractType _selectedType = ContractType.sponsorship;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  String? _selectedTeamId;
  List<Team> _teams = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return FutureBuilder<List<Team>>(
          future: adminProvider.getAllTeams(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            _teams = snapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Contract',
                      style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 24),
                    
                    // Team Selection
                    DropdownButtonFormField<String>(
                      value: _selectedTeamId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Team',
                        border: OutlineInputBorder(),
                      ),
                      items: _teams.map((team) {
                        return DropdownMenuItem(
                          value: team.id,
                          child: Text(
                            team.fullName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTeamId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a team';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Entity Name
                    TextFormField(
                      controller: _entityNameController,
                      decoration: const InputDecoration(
                        labelText: 'Entity Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter entity name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Contract Type
                    DropdownButtonFormField<ContractType>(
                      value: _selectedType,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Contract Type',
                        border: OutlineInputBorder(),
                      ),
                      items: ContractType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Start Date
                    ListTile(
                      title: const Text('Start Date'),
                      subtitle: Text(_startDate.toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                          });
                        }
                      },
                    ),
                    
                    // End Date
                    ListTile(
                      title: const Text('End Date'),
                      subtitle: Text(_endDate.toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (date != null) {
                          setState(() {
                            _endDate = date;
                          });
                        }
                      },
                    ),
                    
                    // Value
                    TextFormField(
                      controller: _valueController,
                      decoration: const InputDecoration(
                        labelText: 'Contract Value (\$)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter contract value';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                                         ),
                     const SizedBox(height: 24),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: adminProvider.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                                                     final success = await adminProvider.createContract(
                                     teamId: _selectedTeamId!,
                                     entityName: _entityNameController.text,
                                     type: _selectedType,
                                     startDate: _startDate,
                                     endDate: _endDate,
                                     value: double.parse(_valueController.text),
                                   );
                                  
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Contract created successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                                                         _entityNameController.clear();
                                     _valueController.clear();
                                  } else if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(adminProvider.error ?? 'Failed to create contract'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: adminProvider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Create Contract'),
              ),
            ),
          ],
        ),
      ),
            );
          },
        );
      },
    );
  }
}

class _FinancialRecordsTab extends StatelessWidget {
  const _FinancialRecordsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(
            'Financial Records',
            style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.attach_money, color: AppColors.primary),
              title: const Text('Add Revenue Report'),
              subtitle: const Text('Add new revenue report for a team'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showAddRevenueReportDialog(context),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.trending_up, color: AppColors.primary),
              title: const Text('Add Performance Metrics'),
              subtitle: const Text('Add new performance metrics for a team'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showAddPerformanceMetricsDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRevenueReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddRevenueReportDialog(),
    );
  }

  void _showAddPerformanceMetricsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddPerformanceMetricsDialog(),
    );
  }
}

class _AddRevenueReportTab extends StatefulWidget {
  const _AddRevenueReportTab();

  @override
  State<_AddRevenueReportTab> createState() => _AddRevenueReportTabState();
}

class _AddRevenueReportTabState extends State<_AddRevenueReportTab> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTeamId;
  Quarter _selectedQuarter = Quarter.q1;
  int _selectedYear = DateTime.now().year;
  final _merchandiseController = TextEditingController();
  final _sponsorshipController = TextEditingController();
  final _mediaController = TextEditingController();
  final _otherController = TextEditingController();
  final _previousQuarterController = TextEditingController();
  final _yearOverYearController = TextEditingController();
  List<Team> _teams = [];

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    _teams = await adminProvider.getAllTeams();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Text(
              'Add Revenue Report',
              style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            
            // Team Selection
            DropdownButtonFormField<String>(
              value: _selectedTeamId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Team',
                border: OutlineInputBorder(),
              ),
              items: _teams.map((team) {
                return DropdownMenuItem(
                  value: team.id,
                  child: Text(
                    team.fullName,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTeamId = value;
                });
              },
              validator: (value) {
                if (value == null) return 'Please select a team';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Quarter Selection
            DropdownButtonFormField<Quarter>(
              value: _selectedQuarter,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Quarter',
                border: OutlineInputBorder(),
              ),
              items: Quarter.values.map((quarter) {
                return DropdownMenuItem(
                  value: quarter,
                  child: Text(quarter.toString().split('.').last.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedQuarter = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Year Selection
            DropdownButtonFormField<int>(
              value: _selectedYear,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(),
              ),
              items: List.generate(5, (index) {
                final year = DateTime.now().year - 2 + index;
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Revenue by Type
            Text(
              'Revenue by Type (\$ millions)',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 8),

            TextFormField(
              controller: _merchandiseController,
              decoration: const InputDecoration(
                labelText: 'Merchandise Revenue',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter merchandise revenue';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _sponsorshipController,
              decoration: const InputDecoration(
                labelText: 'Sponsorship Revenue',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter sponsorship revenue';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _mediaController,
              decoration: const InputDecoration(
                labelText: 'Media Revenue',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter media revenue';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _otherController,
              decoration: const InputDecoration(
                labelText: 'Other Revenue',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter other revenue';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Previous Quarter Revenue
            TextFormField(
              controller: _previousQuarterController,
              decoration: const InputDecoration(
                labelText: 'Previous Quarter Revenue (\$ millions)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter previous quarter revenue';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Year over Year Growth
            TextFormField(
              controller: _yearOverYearController,
              decoration: const InputDecoration(
                labelText: 'Year over Year Growth (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter year over year growth';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: Consumer<AdminProvider>(
                builder: (context, adminProvider, child) {
                  return ElevatedButton(
                    onPressed: adminProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final revenueByType = {
                                RevenueType.merchandise: double.parse(_merchandiseController.text),
                                RevenueType.sponsorship: double.parse(_sponsorshipController.text),
                                RevenueType.media: double.parse(_mediaController.text),
                                RevenueType.other: double.parse(_otherController.text),
                              };

                              final totalRevenue = revenueByType.values.reduce((a, b) => a + b);

                              final revenueReport = RevenueReport(
                                teamId: _selectedTeamId!,
                                quarter: _selectedQuarter,
                                year: _selectedYear,
                                revenueByType: revenueByType,
                                totalRevenue: totalRevenue,
                                previousQuarterRevenue: double.parse(_previousQuarterController.text),
                                yearOverYearGrowth: double.parse(_yearOverYearController.text),
                                reportDate: DateTime.now(),
                              );

                              final success = await adminProvider.updateFinancialRecords(
                                teamId: _selectedTeamId!,
                                revenueReport: revenueReport,
                              );

                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Revenue report added successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _clearForm();
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(adminProvider.error ?? 'Failed to add revenue report'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: adminProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Add Revenue Report'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearForm() {
    _merchandiseController.clear();
    _sponsorshipController.clear();
    _mediaController.clear();
    _otherController.clear();
    _previousQuarterController.clear();
    _yearOverYearController.clear();
    setState(() {
      _selectedTeamId = null;
      _selectedQuarter = Quarter.q1;
      _selectedYear = DateTime.now().year;
    });
  }
}

class _AddPerformanceMetricsTab extends StatefulWidget {
  const _AddPerformanceMetricsTab();

  @override
  State<_AddPerformanceMetricsTab> createState() => _AddPerformanceMetricsTabState();
}

class _AddPerformanceMetricsTabState extends State<_AddPerformanceMetricsTab> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTeamId;
  int _selectedSeason = DateTime.now().year;
  final _winsController = TextEditingController();
  final _lossesController = TextEditingController();
  final _merchandiseRevenueController = TextEditingController();
  final _totalRevenueController = TextEditingController();
  final _payrollController = TextEditingController();
  List<Team> _teams = [];

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    _teams = await adminProvider.getAllTeams();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Text(
              'Add Performance Metrics',
              style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            
            // Team Selection
            DropdownButtonFormField<String>(
              value: _selectedTeamId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Team',
                border: OutlineInputBorder(),
              ),
              items: _teams.map((team) {
                return DropdownMenuItem(
                  value: team.id,
                  child: Text(
                    team.fullName,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTeamId = value;
                });
              },
              validator: (value) {
                if (value == null) return 'Please select a team';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Season Selection
            DropdownButtonFormField<int>(
              value: _selectedSeason,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Season',
                border: OutlineInputBorder(),
              ),
              items: List.generate(5, (index) {
                final year = DateTime.now().year - 2 + index;
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _selectedSeason = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Wins
            TextFormField(
              controller: _winsController,
              decoration: const InputDecoration(
                labelText: 'Wins',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter wins';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Losses
            TextFormField(
              controller: _lossesController,
              decoration: const InputDecoration(
                labelText: 'Losses',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter losses';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Merchandise Revenue
            TextFormField(
              controller: _merchandiseRevenueController,
              decoration: const InputDecoration(
                labelText: 'Merchandise Revenue (\$ millions)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter merchandise revenue';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Total Revenue
            TextFormField(
              controller: _totalRevenueController,
              decoration: const InputDecoration(
                labelText: 'Total Revenue (\$ millions)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total revenue';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Payroll
            TextFormField(
              controller: _payrollController,
              decoration: const InputDecoration(
                labelText: 'Payroll (\$ millions)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter payroll';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: Consumer<AdminProvider>(
                builder: (context, adminProvider, child) {
                  return ElevatedButton(
                    onPressed: adminProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final wins = int.parse(_winsController.text);
                              final losses = int.parse(_lossesController.text);
                              final totalGames = wins + losses;
                              final winPercentage = totalGames > 0 ? (wins / totalGames) * 100 : 0.0;

                              final totalRevenue = double.parse(_totalRevenueController.text);
                              final payroll = double.parse(_payrollController.text);
                              final profitMargin = totalRevenue > 0 ? ((totalRevenue - payroll) / totalRevenue) * 100 : 0.0;

                              final performanceMetrics = PerformanceMetrics(
                                teamId: _selectedTeamId!,
                                season: _selectedSeason,
                                wins: wins,
                                losses: losses,
                                winPercentage: winPercentage,
                                merchandiseRevenue: double.parse(_merchandiseRevenueController.text),
                                totalRevenue: totalRevenue,
                                payroll: payroll,
                                profitMargin: profitMargin,
                              );

                              final success = await adminProvider.updatePerformanceMetrics(
                                teamId: _selectedTeamId!,
                                metrics: performanceMetrics,
                              );

                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Performance metrics added successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _clearForm();
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(adminProvider.error ?? 'Failed to add performance metrics'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: adminProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Add Performance Metrics'),
                  );
                },
              ),
              ),
            ],
          ),
        ),
    );
  }

  void _clearForm() {
    _winsController.clear();
    _lossesController.clear();
    _merchandiseRevenueController.clear();
    _totalRevenueController.clear();
    _payrollController.clear();
    setState(() {
      _selectedTeamId = null;
      _selectedSeason = DateTime.now().year;
    });
  }
}

class _AddRevenueReportDialog extends StatefulWidget {
  @override
  State<_AddRevenueReportDialog> createState() => _AddRevenueReportDialogState();
}

class _AddRevenueReportDialogState extends State<_AddRevenueReportDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTeamId;
  Quarter _selectedQuarter = Quarter.q1;
  int _selectedYear = DateTime.now().year;
  final _merchandiseController = TextEditingController();
  final _sponsorshipController = TextEditingController();
  final _mediaController = TextEditingController();
  final _otherController = TextEditingController();
  final _previousQuarterController = TextEditingController();
  final _yearOverYearController = TextEditingController();
  List<Team> _teams = [];

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    _teams = await adminProvider.getAllTeams();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Revenue Report',
                  style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Team Selection
                      DropdownButtonFormField<String>(
                        value: _selectedTeamId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Team',
                          border: OutlineInputBorder(),
                        ),
                        items: _teams.map((team) {
                          return DropdownMenuItem(
                            value: team.id,
                            child: Text(
                              team.fullName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTeamId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) return 'Please select a team';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Quarter Selection
                      DropdownButtonFormField<Quarter>(
                        value: _selectedQuarter,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Quarter',
                          border: OutlineInputBorder(),
                        ),
                        items: Quarter.values.map((quarter) {
                          return DropdownMenuItem(
                            value: quarter,
                            child: Text(quarter.toString().split('.').last.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedQuarter = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Year Selection
                      DropdownButtonFormField<int>(
                        value: _selectedYear,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(5, (index) {
                          final year = DateTime.now().year - 2 + index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Revenue by Type
                      Text(
                        'Revenue by Type (\$ millions)',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _merchandiseController,
                        decoration: const InputDecoration(
                          labelText: 'Merchandise Revenue',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter merchandise revenue';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _sponsorshipController,
                        decoration: const InputDecoration(
                          labelText: 'Sponsorship Revenue',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter sponsorship revenue';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _mediaController,
                        decoration: const InputDecoration(
                          labelText: 'Media Revenue',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter media revenue';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _otherController,
                        decoration: const InputDecoration(
                          labelText: 'Other Revenue',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter other revenue';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Previous Quarter Revenue
                      TextFormField(
                        controller: _previousQuarterController,
                        decoration: const InputDecoration(
                          labelText: 'Previous Quarter Revenue (\$ millions)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter previous quarter revenue';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Year over Year Growth
                      TextFormField(
                        controller: _yearOverYearController,
                        decoration: const InputDecoration(
                          labelText: 'Year over Year Growth (%)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter year over year growth';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: Consumer<AdminProvider>(
                          builder: (context, adminProvider, child) {
                            return ElevatedButton(
                              onPressed: adminProvider.isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        final revenueByType = {
                                          RevenueType.merchandise: double.parse(_merchandiseController.text),
                                          RevenueType.sponsorship: double.parse(_sponsorshipController.text),
                                          RevenueType.media: double.parse(_mediaController.text),
                                          RevenueType.other: double.parse(_otherController.text),
                                        };

                                        final totalRevenue = revenueByType.values.reduce((a, b) => a + b);

                                        final revenueReport = RevenueReport(
                                          teamId: _selectedTeamId!,
                                          quarter: _selectedQuarter,
                                          year: _selectedYear,
                                          revenueByType: revenueByType,
                                          totalRevenue: totalRevenue,
                                          previousQuarterRevenue: double.parse(_previousQuarterController.text),
                                          yearOverYearGrowth: double.parse(_yearOverYearController.text),
                                          reportDate: DateTime.now(),
                                        );

                                        final success = await adminProvider.updateFinancialRecords(
                                          teamId: _selectedTeamId!,
                                          revenueReport: revenueReport,
                                        );

                                        if (success && mounted) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Revenue report added successfully!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(adminProvider.error ?? 'Failed to add revenue report'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: adminProvider.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Add Revenue Report'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPerformanceMetricsDialog extends StatefulWidget {
  @override
  State<_AddPerformanceMetricsDialog> createState() => _AddPerformanceMetricsDialogState();
}

class _AddPerformanceMetricsDialogState extends State<_AddPerformanceMetricsDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTeamId;
  int _selectedSeason = DateTime.now().year;
  final _winsController = TextEditingController();
  final _lossesController = TextEditingController();
  final _merchandiseRevenueController = TextEditingController();
  final _totalRevenueController = TextEditingController();
  final _payrollController = TextEditingController();
  List<Team> _teams = [];

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    _teams = await adminProvider.getAllTeams();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Performance Metrics',
                  style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
                ),
                IconButton(
            onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Team Selection
                      DropdownButtonFormField<String>(
                        value: _selectedTeamId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Team',
                          border: OutlineInputBorder(),
                        ),
                        items: _teams.map((team) {
                          return DropdownMenuItem(
                            value: team.id,
                            child: Text(
                              team.fullName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTeamId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) return 'Please select a team';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Season Selection
                      DropdownButtonFormField<int>(
                        value: _selectedSeason,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Season',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(5, (index) {
                          final year = DateTime.now().year - 2 + index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            _selectedSeason = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Wins
                      TextFormField(
                        controller: _winsController,
                        decoration: const InputDecoration(
                          labelText: 'Wins',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter wins';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Losses
                      TextFormField(
                        controller: _lossesController,
                        decoration: const InputDecoration(
                          labelText: 'Losses',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter losses';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Merchandise Revenue
                      TextFormField(
                        controller: _merchandiseRevenueController,
                        decoration: const InputDecoration(
                          labelText: 'Merchandise Revenue (\$ millions)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter merchandise revenue';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Total Revenue
                      TextFormField(
                        controller: _totalRevenueController,
                        decoration: const InputDecoration(
                          labelText: 'Total Revenue (\$ millions)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter total revenue';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Payroll
                      TextFormField(
                        controller: _payrollController,
                        decoration: const InputDecoration(
                          labelText: 'Payroll (\$ millions)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter payroll';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: Consumer<AdminProvider>(
                          builder: (context, adminProvider, child) {
                            return ElevatedButton(
                              onPressed: adminProvider.isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        final wins = int.parse(_winsController.text);
                                        final losses = int.parse(_lossesController.text);
                                        final totalGames = wins + losses;
                                        final winPercentage = totalGames > 0 ? (wins / totalGames) * 100 : 0.0;

                                        final totalRevenue = double.parse(_totalRevenueController.text);
                                        final payroll = double.parse(_payrollController.text);
                                        final profitMargin = totalRevenue > 0 ? ((totalRevenue - payroll) / totalRevenue) * 100 : 0.0;

                                        final performanceMetrics = PerformanceMetrics(
                                          teamId: _selectedTeamId!,
                                          season: _selectedSeason,
                                          wins: wins,
                                          losses: losses,
                                          winPercentage: winPercentage,
                                          merchandiseRevenue: double.parse(_merchandiseRevenueController.text),
                                          totalRevenue: totalRevenue,
                                          payroll: payroll,
                                          profitMargin: profitMargin,
                                        );

                                        final success = await adminProvider.updatePerformanceMetrics(
                                          teamId: _selectedTeamId!,
                                          metrics: performanceMetrics,
                                        );

                                        if (success && mounted) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Performance metrics added successfully!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(adminProvider.error ?? 'Failed to add performance metrics'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: adminProvider.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Add Performance Metrics'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 