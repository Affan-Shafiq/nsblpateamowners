import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
                    'NSBLPA Ownership Resources',
                    Icons.business,
                    _buildOwnershipLinks(context),
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
                Expanded(
                  child: Text(
                  title,
                  style: AppTextStyles.heading2,
                    overflow: TextOverflow.ellipsis,
                  ),
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







  Widget _buildOwnershipLinks(BuildContext context) {
    final ownershipLinks = [
      {
        'title': 'Board Governance',
        'description': 'Learn about board structure and governance policies',
        'url': 'https://nsblpa.com/ownership/boardgovernance.html',
      },
      {
        'title': 'Team Ownership',
        'description': 'Understanding team ownership requirements and processes',
        'url': 'https://nsblpa.com/ownership/teamownership.html',
      },
      {
        'title': 'Revenue Sharing with Players',
        'description': 'Guidelines for revenue sharing agreements with players',
        'url': 'https://nsblpa.com/ownership/revenuesharingplayers.html',
      },
      {
        'title': 'Player Revenue Share',
        'description': 'Detailed breakdown of player revenue sharing models',
        'url': 'https://nsblpa.com/ownership/playerrevenueshare.html',
      },
      {
        'title': 'Player Compensation Structure',
        'description': 'Understanding player compensation and salary structures',
        'url': 'https://nsblpa.com/ownership/playercompensationstructure.html',
      },
      {
        'title': 'Team Revenue and Player Relationship',
        'description': 'How team revenue affects player relationships',
        'url': 'https://nsblpa.com/ownership/teamrevenueplayerrelationship.html',
      },
      {
        'title': 'Revenue Sharing Across Teams',
        'description': 'League-wide revenue sharing mechanisms',
        'url': 'https://nsblpa.com/ownership/revenuesharingacrossteams.html',
      },
      {
        'title': 'Detailed Breakdown of Revenue Allocation',
        'description': 'Complete guide to revenue allocation and distribution',
        'url': 'https://nsblpa.com/ownership/detailedbreakdownrevenueallocation.html',
      },
    ];

    return Column(
      children: ownershipLinks.map((link) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.link, color: AppColors.primary),
          title: Text(
              link['title']!,
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
              link['description']!,
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
            trailing: const Icon(Icons.open_in_new, color: AppColors.primary),
            onTap: () => _launchURL(context, link['url']!),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    try {
      print('🔗 [DEBUG] Attempting to launch URL: $url');
      
      // Try to launch URL with url_launcher first
      final Uri uri = Uri.parse(url);
      final result = await launchUrl(uri);
      print('🔗 [DEBUG] Launch result: $result');
      
      if (result) {
        return; // Successfully launched
      }
    } catch (e) {
      print('❌ [ERROR] url_launcher failed: $e');
    }
    
    // If url_launcher fails, show web view dialog
    if (context.mounted) {
      _showWebViewDialog(context, url);
    }
  }
  
  void _showWebViewDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
          children: [
                      Expanded(
                        child: Text(
                          'NSBLPA Ownership',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
                ),
                // Web View
                Expanded(
                  child: WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..loadRequest(Uri.parse(url)),
                  ),
          ),
        ],
      ),
          ),
        );
      },
    );
  }

  void _showComingSoon(String feature) {
    // This would show a dialog in a real implementation
    // For now, just print to console
    print('$feature feature coming soon');
  }
} 