import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/communication.dart';

class CommunicationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Communication> _communications = [];
  bool _isLoading = false;
  String? _error;

  List<Communication> get communications => _communications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get communications for a specific team
  List<Communication> getCommunicationsByTeam(String teamId) {
    return _communications.where((comm) => comm.teamId == teamId).toList();
  }

  // Fetch communications for a specific team
  Future<void> fetchCommunications(String teamId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔍 [DEBUG] fetchCommunications called with teamId: $teamId');

      final querySnapshot = await _firestore
          .collection('communications')
          .where('teamId', isEqualTo: teamId)
          .orderBy('createdAt', descending: true)
          .get();

      print('🔍 [DEBUG] Communications query completed. Found ${querySnapshot.docs.length} documents');

      _communications = querySnapshot.docs.map((doc) {
        return Communication.fromJson(doc.data(), documentId: doc.id);
      }).toList();

      print('🔍 [DEBUG] Parsed ${_communications.length} communications');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ [ERROR] Failed to load communications: $e');
      _error = 'Failed to load communications: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send a new communication
  Future<void> sendCommunication(Communication communication) async {
    try {
      print('🔍 [DEBUG] sendCommunication called');
      print('🔍 [DEBUG] Communication data: ${communication.toJson()}');

      final docRef = await _firestore.collection('communications').add(communication.toJson());
      
      final newCommunication = Communication(
        documentId: docRef.id,
        teamId: communication.teamId,
        subject: communication.subject,
        message: communication.message,
        type: communication.type,
        senderId: communication.senderId,
        senderName: communication.senderName,
        createdAt: communication.createdAt,
        isRead: communication.isRead,
      );

      _communications.insert(0, newCommunication);
      notifyListeners();

      print('🔍 [DEBUG] Communication sent successfully with ID: ${docRef.id}');
    } catch (e) {
      print('❌ [ERROR] Failed to send communication: $e');
      throw Exception('Failed to send communication: $e');
    }
  }

  // Mark communication as read
  Future<void> markAsRead(String communicationId) async {
    try {
      await _firestore.collection('communications').doc(communicationId).update({
        'isRead': true,
      });

      final index = _communications.indexWhere((comm) => comm.documentId == communicationId);
      if (index != -1) {
        final updatedCommunication = Communication(
          documentId: _communications[index].documentId,
          teamId: _communications[index].teamId,
          subject: _communications[index].subject,
          message: _communications[index].message,
          type: _communications[index].type,
          senderId: _communications[index].senderId,
          senderName: _communications[index].senderName,
          createdAt: _communications[index].createdAt,
          isRead: true,
        );
        _communications[index] = updatedCommunication;
        notifyListeners();
      }
    } catch (e) {
      print('❌ [ERROR] Failed to mark communication as read: $e');
    }
  }

  // Delete a communication
  Future<void> deleteCommunication(String communicationId) async {
    try {
      await _firestore.collection('communications').doc(communicationId).delete();
      
      _communications.removeWhere((comm) => comm.documentId == communicationId);
      notifyListeners();
    } catch (e) {
      print('❌ [ERROR] Failed to delete communication: $e');
      throw Exception('Failed to delete communication: $e');
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 