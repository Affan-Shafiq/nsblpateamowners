import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NSBLPA Admin Panel'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Administrative Controls',
              style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildAdminCard(
                    context,
                    'Document Management',
                    Icons.description,
                    'Upload and manage NSBLPA documents',
                    () => _showComingSoon(context, 'Document Management'),
                  ),
                  _buildAdminCard(
                    context,
                    'Announcements',
                    Icons.announcement,
                    'Post league-wide announcements',
                    () => _showComingSoon(context, 'Announcements'),
                  ),
                  _buildAdminCard(
                    context,
                    'Ownership Changes',
                    Icons.swap_horiz,
                    'Manage team ownership transfers',
                    () => _showComingSoon(context, 'Ownership Changes'),
                  ),
                  _buildAdminCard(
                    context,
                    'Financial Statements',
                    Icons.account_balance,
                    'Upload quarterly financial reports',
                    () => _showComingSoon(context, 'Financial Statements'),
                  ),
                  _buildAdminCard(
                    context,
                    'Team Management',
                    Icons.admin_panel_settings,
                    'Add new teams to the league',
                    () => _showComingSoon(context, 'Team Management'),
                  ),
                  _buildAdminCard(
                    context,
                    'User Management',
                    Icons.people,
                    'Manage team owner accounts',
                    () => _showComingSoon(context, 'User Management'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature Coming Soon'),
        content: Text('This feature is currently under development and will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 