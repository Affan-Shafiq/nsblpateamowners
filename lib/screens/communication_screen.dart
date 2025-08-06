import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../models/communication.dart';
import '../providers/communication_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class CommunicationScreen extends StatefulWidget {
  final Team team;

  const CommunicationScreen({super.key, required this.team});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  final _messageController = TextEditingController();
  final _subjectController = TextEditingController();
  MessageType _selectedType = MessageType.memo;

  @override
  void dispose() {
    _messageController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunicationProvider>().fetchCommunications(widget.team.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.team.name} Communication'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CommunicationProvider>(
        builder: (context, communicationProvider, child) {
          if (communicationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (communicationProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${communicationProvider.error}',
                    style: AppTextStyles.body1.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      communicationProvider.clearError();
                      if (widget.team != null) {
                        communicationProvider.fetchCommunications(widget.team!.id);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final communications = communicationProvider.getCommunicationsByTeam(widget.team.id);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Team Communication',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                
                // Quick Actions
                _buildQuickActions(),
                const SizedBox(height: AppSizes.paddingLarge),
                
                // Send Message Form
                _buildMessageForm(),
                const SizedBox(height: AppSizes.paddingLarge),
                
                // Recent Messages
                _buildRecentMessages(communications),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Row(
              children: [
                                 Expanded(
                   child: _buildActionButton(
                     'Team Memo',
                     Icons.message,
                     AppColors.primary,
                     () => _showQuickMessageDialog(MessageType.memo),
                   ),
                 ),
                 const SizedBox(width: AppSizes.paddingMedium),
                 Expanded(
                   child: _buildActionButton(
                     'Investor Update',
                     Icons.business,
                     AppColors.accent,
                     () => _showQuickMessageDialog(MessageType.investorUpdate),
                   ),
                 ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              title,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Message',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Message Type
            DropdownButtonFormField<MessageType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Message Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: MessageType.memo, child: Text('Memo')),
                DropdownMenuItem(value: MessageType.update, child: Text('Update')),
                DropdownMenuItem(value: MessageType.alert, child: Text('Alert')),
                DropdownMenuItem(value: MessageType.meeting, child: Text('Meeting')),
                DropdownMenuItem(value: MessageType.investorUpdate, child: Text('Investor Update')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Subject
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Message
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Send Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendMessage,
                child: const Text('Send Message'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMessages(List<Communication> communications) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Messages',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            
            if (communications.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                child: Text(
                  'No messages yet',
                  style: AppTextStyles.body2,
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...communications.map((communication) => _buildMessageItem(communication)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(Communication communication) {
    Color color;
    switch (communication.type) {
      case MessageType.memo:
        color = AppColors.primary;
        break;
      case MessageType.investorUpdate:
        color = AppColors.accent;
        break;
      case MessageType.alert:
        color = AppColors.error;
        break;
      case MessageType.meeting:
        color = AppColors.success;
        break;
      case MessageType.update:
        color = AppColors.secondary;
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(
          _getMessageTypeIcon(communication.type),
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        communication.subject,
        style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${communication.typeDisplayName} • ${communication.timeAgo} • ${communication.senderName}',
        style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showMessageOptions(communication),
      ),
    );
  }

  IconData _getMessageTypeIcon(MessageType type) {
    switch (type) {
      case MessageType.memo:
        return Icons.message;
      case MessageType.investorUpdate:
        return Icons.business;
      case MessageType.alert:
        return Icons.warning;
      case MessageType.meeting:
        return Icons.schedule;
      case MessageType.update:
        return Icons.update;
    }
  }

  String _getMessageTypeDisplayName(MessageType type) {
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

  void _sendMessage() async {
    if (_subjectController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }



    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUserModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
             final communication = Communication(
         teamId: widget.team.id,
         subject: _subjectController.text,
         message: _messageController.text,
         type: _selectedType,
         senderId: authProvider.userId!,
         senderName: authProvider.currentUserModel!.name,
         createdAt: DateTime.now(),
       );

      await context.read<CommunicationProvider>().sendCommunication(communication);

             ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('${_getMessageTypeDisplayName(_selectedType)} sent successfully'),
           backgroundColor: AppColors.success,
         ),
       );

      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _selectedType = MessageType.memo;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showQuickMessageDialog(MessageType type) {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send ${_getMessageTypeDisplayName(type)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (subjectController.text.isEmpty || messageController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              Navigator.of(context).pop();

              

              final authProvider = context.read<AuthProvider>();
              if (authProvider.currentUserModel == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User not authenticated'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              try {
                                 final communication = Communication(
                   teamId: widget.team.id,
                   subject: subjectController.text,
                   message: messageController.text,
                   type: type,
                   senderId: authProvider.userId!,
                   senderName: authProvider.currentUserModel!.name,
                   createdAt: DateTime.now(),
                 );

                await context.read<CommunicationProvider>().sendCommunication(communication);

                                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text('${_getMessageTypeDisplayName(type)} sent successfully'),
                     backgroundColor: AppColors.success,
                   ),
                 );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to send message: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }



  void _showMessageOptions(Communication communication) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('View Details'),
            onTap: () {
              Navigator.of(context).pop();
              _showMessageDetails(communication);
            },
          ),
          if (!communication.isRead)
            ListTile(
              leading: const Icon(Icons.mark_email_read),
              title: const Text('Mark as Read'),
              onTap: () async {
                Navigator.of(context).pop();
                if (communication.documentId != null) {
                  await context.read<CommunicationProvider>().markAsRead(communication.documentId!);
                }
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () async {
              Navigator.of(context).pop();
              if (communication.documentId != null) {
                try {
                  await context.read<CommunicationProvider>().deleteCommunication(communication.documentId!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete message: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showMessageDetails(Communication communication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(communication.subject),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${communication.typeDisplayName}'),
            const SizedBox(height: 8),
            Text('From: ${communication.senderName}'),
            const SizedBox(height: 8),
            Text('Date: ${communication.createdAt.toString().split('.')[0]}'),
            const SizedBox(height: 16),
            Text('Message:'),
            const SizedBox(height: 8),
            Text(communication.message),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 