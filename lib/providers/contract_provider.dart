import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contract.dart';

class ContractProvider with ChangeNotifier {
  List<Contract> _contracts = [];
  bool _isLoading = false;
  String? _error;

  List<Contract> get contracts => _contracts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Contract> get pendingContracts => 
      _contracts.where((contract) => contract.isPending).toList();
  
  List<Contract> get activeContracts => 
      _contracts.where((contract) => contract.isActive).toList();
  
  List<Contract> get expiredContracts => 
      _contracts.where((contract) => contract.isExpired).toList();

  Future<void> fetchContracts(String teamId) async {
    print('🔍 [DEBUG] fetchContracts called with teamId: $teamId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final firestore = FirebaseFirestore.instance;
      print('🔍 [DEBUG] Querying contracts collection for teamId: $teamId');
      
      final querySnapshot = await firestore
          .collection('contracts')
          .where('teamId', isEqualTo: teamId)
          .orderBy('startDate', descending: true)
          .get();

      print('🔍 [DEBUG] Contracts query completed. Found ${querySnapshot.docs.length} documents');
      
      _contracts = querySnapshot.docs.map((doc) {
        print('🔍 [DEBUG] Processing contract document: ${doc.id}');
        print('🔍 [DEBUG] Contract document data: ${doc.data()}');
        return Contract.fromJson(doc.data(), documentId: doc.id);
      }).toList();
      
      print('🔍 [DEBUG] Parsed ${_contracts.length} contracts');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ [ERROR] Failed to load contracts: $e');
      _error = 'Failed to load contracts: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllContracts() async {
    print('🔍 [DEBUG] fetchAllContracts called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final firestore = FirebaseFirestore.instance;
      print('🔍 [DEBUG] Fetching all contracts documents');
      
      final querySnapshot = await firestore
          .collection('contracts')
          .orderBy('startDate', descending: true)
          .get();

      print('🔍 [DEBUG] Found ${querySnapshot.docs.length} contracts');

      _contracts = querySnapshot.docs.map((doc) {
        return Contract.fromJson(doc.data(), documentId: doc.id);
      }).toList();
      
      print('🔍 [DEBUG] Total contracts: ${_contracts.length}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ [ERROR] Failed to load all contracts: $e');
      _error = 'Failed to load contracts: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Contract> getContractsByType(ContractType type) {
    return _contracts.where((contract) => contract.type == type).toList();
  }

  List<Contract> getContractsByStatus(ContractStatus status) {
    return _contracts.where((contract) => contract.status == status).toList();
  }

  List<Contract> getContractsByTeam(String teamId) {
    print('🔍 [DEBUG] getContractsByTeam called with teamId: $teamId');
    final contracts = _contracts.where((contract) => contract.teamId == teamId).toList();
    print('🔍 [DEBUG] Found ${contracts.length} contracts for teamId: $teamId');
    return contracts;
  }

  Future<void> approveContract(String contractDocumentId, String approvedBy) async {
    try {
      print('🔍 [DEBUG] Approving contract with document ID: $contractDocumentId');
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('contracts').doc(contractDocumentId).update({
        'status': 'active',
        'approvedBy': approvedBy,
      });
      
      // Update local state
      final contractIndex = _contracts.indexWhere((contract) => contract.documentId == contractDocumentId);
      if (contractIndex != -1) {
        final contract = _contracts[contractIndex];
        final updatedContract = Contract(
          documentId: contract.documentId,
          teamId: contract.teamId,
          entityName: contract.entityName,
          type: contract.type,
          status: ContractStatus.active,
          annualValue: contract.annualValue,
          startDate: contract.startDate,
          endDate: contract.endDate,
          approvedBy: approvedBy,
        );
        
        _contracts[contractIndex] = updatedContract;
        notifyListeners();
      }
    } catch (e) {
      print('❌ [ERROR] Failed to approve contract: $e');
      _error = 'Failed to approve contract: $e';
      notifyListeners();
    }
  }

  Future<void> rejectContract(String contractDocumentId, String reason) async {
    try {
      print('🔍 [DEBUG] Rejecting contract with document ID: $contractDocumentId');
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('contracts').doc(contractDocumentId).update({
        'status': 'terminated',
      });
      
      // Update local state
      final contractIndex = _contracts.indexWhere((contract) => contract.documentId == contractDocumentId);
      if (contractIndex != -1) {
        final contract = _contracts[contractIndex];
        final updatedContract = Contract(
          documentId: contract.documentId,
          teamId: contract.teamId,
          entityName: contract.entityName,
          type: contract.type,
          status: ContractStatus.terminated,
          annualValue: contract.annualValue,
          startDate: contract.startDate,
          endDate: contract.endDate,
          approvedBy: contract.approvedBy,
        );
        
        _contracts[contractIndex] = updatedContract;
        notifyListeners();
      }
    } catch (e) {
      print('❌ [ERROR] Failed to reject contract: $e');
      _error = 'Failed to reject contract: $e';
      notifyListeners();
    }
  }

  Future<void> addContract(Contract contract) async {
    try {
      // Add to Firebase
      final firestore = FirebaseFirestore.instance;
      final docRef = await firestore.collection('contracts').add(contract.toJson());
      
      // Add to local state with the new document ID
      final newContract = Contract(
        documentId: docRef.id,
        teamId: contract.teamId,
        entityName: contract.entityName,
        type: contract.type,
        status: contract.status,
        annualValue: contract.annualValue,
        startDate: contract.startDate,
        endDate: contract.endDate,
        approvedBy: contract.approvedBy,
      );
      
      _contracts.add(newContract);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add contract: $e';
      notifyListeners();
    }
  }

  double getTotalContractValue(String teamId) {
    return getContractsByTeam(teamId)
        .where((contract) => contract.isActive)
        .fold(0.0, (sum, contract) => sum + contract.annualValue);
  }

  int getPendingContractsCount(String teamId) {
    return getContractsByTeam(teamId)
        .where((contract) => contract.isPending)
        .length;
  }

  void reset() {
    _contracts = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
} 