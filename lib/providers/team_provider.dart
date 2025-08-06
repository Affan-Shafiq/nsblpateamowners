import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team.dart';
import '../models/user_model.dart';

class TeamProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Team> _teams = [];
  List<Team> _userTeams = [];
  Team? _selectedTeam;
  bool _isLoading = false;
  String? _error;

  List<Team> get teams => _teams;
  List<Team> get userTeams => _userTeams;
  Team? get selectedTeam => _selectedTeam;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTeams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await _firestore.collection('teams').get();
      
      _teams = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Team.fromJson(data, doc.id);
      }).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load teams: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserTeams(UserModel? currentUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (currentUser == null || currentUser.teamsOwned.isEmpty) {
        _userTeams = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get all teams first
      final QuerySnapshot snapshot = await _firestore.collection('teams').get();
      final allTeams = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Team.fromJson(data, doc.id);
      }).toList();

      // Filter teams based on user's teamsOwned
      _userTeams = allTeams.where((team) {
        return currentUser.teamsOwned.any((ownedTeam) => 
          ownedTeam['teamId'] == team.id || ownedTeam['name'] == team.name
        );
      }).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user teams: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTeam(Team team) {
    _selectedTeam = team;
    notifyListeners();
  }

  void clearSelectedTeam() {
    _selectedTeam = null;
    notifyListeners();
  }

  Team? getTeamById(String teamDocId) {
    try {
      return _teams.firstWhere((team) => team.id == teamDocId);
    } catch (e) {
      return null;
    }
  }

  double getTotalPortfolioValue(String ownerId, List<Map<String, dynamic>> teamsOwned) {
    double totalValue = 0.0;
    
    for (Map<String, dynamic> teamOwnership in teamsOwned) {
      final teamId = teamOwnership['teamId'] as String?;
      final stake = (teamOwnership['stake'] ?? 0.0).toDouble();
      
      if (teamId != null) {
        final team = getTeamById(teamId);
        if (team != null) {
          totalValue += team.marketValue * (stake / 100);
        }
      }
    }
    
    return totalValue;
  }

  void reset() {
    _teams = [];
    _userTeams = [];
    _selectedTeam = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
} 