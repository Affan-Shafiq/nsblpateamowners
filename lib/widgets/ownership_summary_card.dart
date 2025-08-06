import 'package:flutter/material.dart';
import '../models/team.dart';
import '../utils/constants.dart';

class OwnershipSummaryCard extends StatelessWidget {
  final Team team;

  const OwnershipSummaryCard({
    super.key,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Team Info Row
          Row(
            children: [
              // Team Logo Placeholder
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: const Icon(
                  Icons.sports_football,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Founded ${team.foundedYear}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingMedium),
          
          // Financial Summary
          Row(
            children: [
              Expanded(
                child: _buildFinancialItem(
                  'Market Value',
                  '\$${(team.marketValue / 1000000).toStringAsFixed(1)}M',
                  Icons.trending_up,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildFinancialItem(
                  'Founded',
                  '${team.foundedYear}',
                  Icons.history,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
} 