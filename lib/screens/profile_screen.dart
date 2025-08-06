import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            _getInitials(user?.displayName ?? 'U'),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.displayName ?? 'User',
                          style: AppTextStyles.heading2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'user@example.com',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Team Owner',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // App Settings
                _buildSection(
                  'App Settings',
                  [
                    _buildMenuItem(
                      'Privacy Policy',
                      Icons.privacy_tip_outlined,
                      () => _launchURL(context, 'https://salesbets.com/privacy.html'),
                    ),
                    _buildMenuItem(
                      'About NSBLPA',
                      Icons.info_outline,
                      () => _launchURL(context, 'https://nsblpa.com/ownership/'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Sign Out
                _buildSection(
                  'Account',
                  [
                    _buildMenuItem(
                      'Sign Out',
                      Icons.logout,
                      () => _showLogoutDialog(context),
                      isDestructive: true,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // App Version
                Center(
                  child: Text(
                    'NSBLPA Team Owners v1.0.0',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty || name == 'U') return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon, 
        color: isDestructive ? AppColors.error : AppColors.primary
      ),
      title: Text(
        title,
        style: AppTextStyles.body1.copyWith(
          color: isDestructive ? AppColors.error : null,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    try {
      print('🔗 [DEBUG] Attempting to launch URL: $url');
      final Uri uri = Uri.parse(url);
      final result = await launchUrl(uri);
      print('🔗 [DEBUG] Launch result: $result');
      
      if (!result && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open link. Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('❌ [ERROR] Failed to launch URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
  }
} 