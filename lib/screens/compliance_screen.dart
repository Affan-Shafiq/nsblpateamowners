import 'package:flutter/material.dart';
import '../models/team.dart';
import '../utils/constants.dart';

class ComplianceScreen extends StatelessWidget {
  final Team team;

  const ComplianceScreen({
    super.key,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${team.name} Compliance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compliance & Documents',
              style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildSection(
                    'NSBLPA Guidelines',
                    Icons.rule,
                    _buildGuidelinesList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.heading2,
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlinesList() {
    final deadlines = [
      {'title': 'Q4 Financial Report', 'date': 'Jan 31, 2024', 'status': 'Pending'},
      {'title': 'Tax Filing Deadline', 'date': 'Apr 15, 2024', 'status': 'Upcoming'},
      {'title': 'Annual Compliance Review', 'date': 'Mar 1, 2024', 'status': 'Pending'},
      {'title': 'Player Contract Renewals', 'date': 'Feb 28, 2024', 'status': 'In Progress'},
    ];

    return Column(
      children: deadlines.map((deadline) {
        final isUrgent = deadline['status'] == 'Pending';
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isUrgent ? AppColors.warning : AppColors.success,
            child: Icon(
              isUrgent ? Icons.warning : Icons.check,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            deadline['title']!,
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'Due: ${deadline['date']}',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          trailing: Chip(
            label: Text(
              deadline['status']!,
              style: AppTextStyles.caption.copyWith(color: Colors.white),
            ),
            backgroundColor: isUrgent ? AppColors.warning : AppColors.success,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDocumentsList() {
    final documents = [
      {'name': 'Team Ownership Certificate', 'status': 'Uploaded', 'date': 'Dec 15, 2023'},
      {'name': 'Financial Statements Q3', 'status': 'Uploaded', 'date': 'Oct 31, 2023'},
      {'name': 'Player Contract Templates', 'status': 'Pending', 'date': 'Jan 15, 2024'},
      {'name': 'Stadium Lease Agreement', 'status': 'Uploaded', 'date': 'Nov 20, 2023'},
    ];

    return Column(
      children: documents.map((doc) {
        final isUploaded = doc['status'] == 'Uploaded';
        return ListTile(
          leading: Icon(
            isUploaded ? Icons.cloud_done : Icons.cloud_upload,
            color: isUploaded ? AppColors.success : AppColors.warning,
          ),
          title: Text(
            doc['name']!,
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'Last updated: ${doc['date']}',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showComingSoon('Document Download'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReportsList() {
    final reports = [
      {'name': 'Annual Tax Return 2023', 'type': 'Tax', 'status': 'Filed'},
      {'name': 'Q3 Revenue Report', 'type': 'Financial', 'status': 'Submitted'},
      {'name': 'Compliance Audit Report', 'type': 'Audit', 'status': 'Pending'},
      {'name': 'Player Salary Report', 'type': 'Payroll', 'status': 'Due'},
    ];

    return Column(
      children: reports.map((report) {
        final isFiled = report['status'] == 'Filed' || report['status'] == 'Submitted';
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isFiled ? AppColors.success : AppColors.warning,
            child: Text(
              report['type']![0],
              style: AppTextStyles.body1.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            report['name']!,
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'Type: ${report['type']}',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          trailing: Chip(
            label: Text(
              report['status']!,
              style: AppTextStyles.caption.copyWith(color: Colors.white),
            ),
            backgroundColor: isFiled ? AppColors.success : AppColors.warning,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGuidelinesList() {
    final guidelines = [
      'Team ownership transfer procedures',
      'Financial reporting requirements',
      'Player contract regulations',
      'Stadium and facility standards',
      'Media and sponsorship guidelines',
      'League compliance policies',
    ];

    return Column(
      children: guidelines.map((guideline) {
        return ListTile(
          leading: const Icon(Icons.article, color: AppColors.primary),
          title: Text(
            guideline,
            style: AppTextStyles.body1,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showComingSoon('Guideline Details'),
        );
      }).toList(),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select document type:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Financial Report'),
              onTap: () {
                Navigator.of(context).pop();
                _showComingSoon('Document Upload');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Compliance Report'),
              onTap: () {
                Navigator.of(context).pop();
                _showComingSoon('Document Upload');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Tax Document'),
              onTap: () {
                Navigator.of(context).pop();
                _showComingSoon('Document Upload');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    // This would show a dialog in a real implementation
    // For now, just print to console
    print('$feature feature coming soon');
  }
} 