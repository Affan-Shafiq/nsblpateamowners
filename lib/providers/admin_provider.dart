import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team.dart';
import '../models/contract.dart';
import '../models/finance.dart';
import '../models/user_model.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Add new team
  Future<bool> addTeam({
    required String name,
    required String city,
    required double marketValue,
    required int foundedYear,
    required String ownerEmail,
    required String ownerName,
    required double ownerStake,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create team document
      final teamData = {
        'name': name,
        'city': city,
        'marketValue': marketValue,
        'foundedYear': foundedYear,
        'logo': '', // Default empty logo
      };

      final teamDocRef = await _firestore.collection('teams').add(teamData);
      final teamId = teamDocRef.id;

      // Find user by email and update their teamsOwned
      final usersQuery = await _firestore.collection('users').where('email', isEqualTo: ownerEmail).get();
      if (usersQuery.docs.isNotEmpty) {
        final ownerDoc = usersQuery.docs.first;
        final ownerData = ownerDoc.data();
        final teamsOwned = List<Map<String, dynamic>>.from(ownerData['teamsOwned'] ?? []);
        
        teamsOwned.add({
          'teamId': teamId,
          'name': name,
          'stake': ownerStake,
        });

        await _firestore.collection('users').doc(ownerDoc.id).update({
          'teamsOwned': teamsOwned,
        });
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add team: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Create contract for owner approval
  Future<bool> createContract({
    required String teamId,
    required String entityName,
    required ContractType type,
    required DateTime startDate,
    required DateTime endDate,
    required double value,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final contractData = {
        'teamId': teamId,
        'entityName': entityName,
        'type': type.toString().split('.').last,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'annualValue': value,
        'status': ContractStatus.pending.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('contracts').add(contractData);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create contract: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update financial records
  Future<bool> updateFinancialRecords({
    required String teamId,
    required RevenueReport revenueReport,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore.collection('RevenueReport').add(revenueReport.toJson());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update financial records: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update performance metrics
  Future<bool> updatePerformanceMetrics({
    required String teamId,
    required PerformanceMetrics metrics,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore.collection('perfMetrics').add(metrics.toJson());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update performance metrics: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get all users for team assignment
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      _error = 'Failed to fetch users: $e';
      notifyListeners();
      return [];
    }
  }

  // Get all teams
  Future<List<Team>> getAllTeams() async {
    try {
      final querySnapshot = await _firestore.collection('teams').get();
      return querySnapshot.docs
          .map((doc) => Team.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _error = 'Failed to fetch teams: $e';
      notifyListeners();
      return [];
    }
  }
} 