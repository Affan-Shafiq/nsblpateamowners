import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../providers/auth_provider.dart';
import '../models/team.dart';
import '../utils/constants.dart';
import '../widgets/team_card.dart';
import 'team_dashboard_screen.dart';

class TeamSelectorScreen extends StatefulWidget {
  const TeamSelectorScreen({super.key});

  @override
  State<TeamSelectorScreen> createState() => _TeamSelectorScreenState();
}

class _TeamSelectorScreenState extends State<TeamSelectorScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final teamProvider = context.read<TeamProvider>();
      
      // Fetch user's teams based on their ownership
      teamProvider.fetchUserTeams(authProvider.currentUserModel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Teams',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Teams Grid
          Expanded(
            child: Consumer<TeamProvider>(
              builder: (context, teamProvider, child) {
                if (teamProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (teamProvider.error != null) {
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
                          'Error loading teams',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Text(
                          teamProvider.error!,
                          style: AppTextStyles.body2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.paddingMedium),
                        ElevatedButton(
                          onPressed: () {
                            final authProvider = context.read<AuthProvider>();
                            teamProvider.fetchUserTeams(authProvider.currentUserModel);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final userTeams = teamProvider.userTeams;
                
                if (userTeams.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_football_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: AppSizes.paddingMedium),
                        Text(
                          'No teams owned',
                          style: AppTextStyles.heading3,
                        ),
                        SizedBox(height: AppSizes.paddingSmall),
                        Text(
                          'You don\'t own any teams yet',
                          style: AppTextStyles.body2,
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: AppSizes.paddingMedium,
                    mainAxisSpacing: AppSizes.paddingMedium,
                  ),
                  itemCount: userTeams.length,
                  itemBuilder: (context, index) {
                    final team = userTeams[index];
                    return TeamCard(
                      team: team,
                      onTap: () => _onTeamSelected(team),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onTeamSelected(Team team) {
    context.read<TeamProvider>().selectTeam(team);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamDashboardScreen(team: team),
      ),
    );
  }
} 