import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  memo,
  update,
  alert,
  meeting,
  investorUpdate,
}

class Communication {
  final String? documentId; // Firebase document ID
  final String teamId;
  final String subject;
  final String message;
  final MessageType type;
  final String senderId;
  final String senderName;
  final DateTime createdAt;
  final bool isRead;

  Communication({
    this.documentId,
    required this.teamId,
    required this.subject,
    required this.message,
    required this.type,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    this.isRead = false,
  });

  factory Communication.fromJson(Map<String, dynamic> json, {String? documentId}) {
    MessageType messageType;
    switch (json['type']) {
      case 'memo':
        messageType = MessageType.memo;
        break;
      case 'update':
        messageType = MessageType.update;
        break;
      case 'alert':
        messageType = MessageType.alert;
        break;
      case 'meeting':
        messageType = MessageType.meeting;
        break;
      case 'investorUpdate':
        messageType = MessageType.investorUpdate;
        break;
      default:
        messageType = MessageType.memo;
    }

    DateTime createdAt;
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt']);
    } else {
      createdAt = DateTime.now();
    }

    return Communication(
      documentId: documentId,
      teamId: json['teamId'] ?? '',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      type: messageType,
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      createdAt: createdAt,
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    String typeString;
    switch (type) {
      case MessageType.memo:
        typeString = 'memo';
        break;
      case MessageType.update:
        typeString = 'update';
        break;
      case MessageType.alert:
        typeString = 'alert';
        break;
      case MessageType.meeting:
        typeString = 'meeting';
        break;
      case MessageType.investorUpdate:
        typeString = 'investorUpdate';
        break;
    }

    return {
      'teamId': teamId,
      'subject': subject,
      'message': message,
      'type': typeString,
      'senderId': senderId,
      'senderName': senderName,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }

  String get typeDisplayName {
    switch (type) {
      case MessageType.memo:
        return 'Team Memo';
      case MessageType.update:
        return 'Update';
      case MessageType.alert:
        return 'Alert';
      case MessageType.meeting:
        return 'Meeting';
      case MessageType.investorUpdate:
        return 'Investor Update';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
} 