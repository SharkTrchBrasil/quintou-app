import 'package:quintou_app/features/chat/data/models/conversation_model.dart';

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final ChatUser? sender;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.sender,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversationId'] ?? json['conversation_id'],
      senderId: json['senderId'] ?? json['sender_id'],
      content: json['content'],
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      sender: json['sender'] != null ? ChatUser.fromJson(json['sender']) : null,
    );
  }
}
