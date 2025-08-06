class UserModel {
  final String name;
  final String email;
  final String role;
  final List<Map<String, dynamic>> teamsOwned; // List of maps with name, stake, and teamId

  UserModel({
    required this.name,
    required this.email,
    required this.role,
    required this.teamsOwned,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'teamsOwned': teamsOwned,
    };
  }

  // Create from Map (from Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'owner',
      teamsOwned: List<Map<String, dynamic>>.from(map['teamsOwned'] ?? []),
    );
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    List<Map<String, dynamic>>? teamsOwned,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      teamsOwned: teamsOwned ?? this.teamsOwned,
    );
  }

  // Helper method to get stake percentage for a team
  double getStakeForTeam(String teamId) {
    final teamOwnership = teamsOwned.firstWhere(
      (team) => team['teamId'] == teamId,
      orElse: () => {'teamId': teamId, 'stake': 0.0},
    );
    return (teamOwnership['stake'] ?? 0.0).toDouble();
  }

  // Helper method to add or update team ownership
  UserModel addTeamOwnership(String teamId, String teamName, double stake) {
    final updatedTeamsOwned = List<Map<String, dynamic>>.from(teamsOwned);
    final existingIndex = updatedTeamsOwned.indexWhere(
      (team) => team['teamId'] == teamId,
    );
    
    if (existingIndex != -1) {
      updatedTeamsOwned[existingIndex] = {
        'teamId': teamId,
        'name': teamName,
        'stake': stake,
      };
    } else {
      updatedTeamsOwned.add({
        'teamId': teamId,
        'name': teamName,
        'stake': stake,
      });
    }
    
    return copyWith(teamsOwned: updatedTeamsOwned);
  }

  // Helper method to remove team ownership
  UserModel removeTeamOwnership(String teamId) {
    final updatedTeamsOwned = teamsOwned.where(
      (team) => team['teamId'] != teamId,
    ).toList();
    
    return copyWith(teamsOwned: updatedTeamsOwned);
  }
} 