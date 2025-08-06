import 'package:cloud_firestore/cloud_firestore.dart';

enum ContractType { player, coach, vendor }
enum ContractStatus { pending, active, expired, terminated }

class Contract {
  final String? documentId; // Firebase document ID
  final String teamId;
  final String entityName;
  final ContractType type;
  final ContractStatus status;
  final double annualValue;
  final DateTime startDate;
  final DateTime endDate;
  final String? approvedBy;

  Contract({
    this.documentId,
    required this.teamId,
    required this.entityName,
    required this.type,
    required this.status,
    required this.annualValue,
    required this.startDate,
    required this.endDate,
    this.approvedBy,
  });

  factory Contract.fromJson(Map<String, dynamic> json, {String? documentId}) {
    // Handle startDate and endDate which can be either Timestamp or String
    DateTime startDate;
    if (json['startDate'] is Timestamp) {
      startDate = (json['startDate'] as Timestamp).toDate();
    } else if (json['startDate'] is String) {
      startDate = DateTime.parse(json['startDate']);
    } else {
      startDate = DateTime.now();
    }

    DateTime endDate;
    if (json['endDate'] is Timestamp) {
      endDate = (json['endDate'] as Timestamp).toDate();
    } else if (json['endDate'] is String) {
      endDate = DateTime.parse(json['endDate']);
    } else {
      endDate = DateTime.now();
    }

    return Contract(
      documentId: documentId,
      teamId: json['teamId'] ?? '',
      entityName: json['entityName'] ?? '',
      type: ContractType.values.firstWhere(
        (e) => e.toString() == 'ContractType.${json['type']}',
        orElse: () => ContractType.player,
      ),
      status: ContractStatus.values.firstWhere(
        (e) => e.toString() == 'ContractStatus.${json['status']}',
        orElse: () => ContractStatus.pending,
      ),
      annualValue: (json['annualValue'] ?? 0.0).toDouble(),
      startDate: startDate,
      endDate: endDate,
      approvedBy: json['approvedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'entityName': entityName,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'annualValue': annualValue,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'approvedBy': approvedBy,
    };
  }

  bool get isPending => status == ContractStatus.pending;
  bool get isActive => status == ContractStatus.active;
  bool get isExpired => status == ContractStatus.expired;
  
  int get daysRemaining {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }
  
  String get typeDisplayName {
    switch (type) {
      case ContractType.player:
        return 'Player';
      case ContractType.coach:
        return 'Coach';
      case ContractType.vendor:
        return 'Vendor';
    }
  }
  
  String get statusDisplayName {
    switch (status) {
      case ContractStatus.pending:
        return 'Pending Approval';
      case ContractStatus.active:
        return 'Active';
      case ContractStatus.expired:
        return 'Expired';
      case ContractStatus.terminated:
        return 'Terminated';
    }
  }
} 