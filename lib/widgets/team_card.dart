import 'package:flutter/material.dart';
import '../models/team.dart';
import '../utils/constants.dart';

class TeamCard extends StatelessWidget {
  final Team team;
  final VoidCallback onTap;

  const TeamCard({
    super.key,
    required this.team,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team Logo and Name
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder for team logo
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      ),
                      child: Icon(
                        Icons.sports_football,
                        size: 28,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        team.name,
                        style: AppTextStyles.heading3.copyWith(fontSize: 14),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        team.city,
                        style: AppTextStyles.body2.copyWith(fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
                             // Team Info - More compact
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   _buildInfoRow('Founded', '${team.foundedYear}'),
                   const SizedBox(height: 2),
                   _buildInfoRow('Value', '\$${(team.marketValue / 1000000).toStringAsFixed(1)}M'),
                 ],
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
} 