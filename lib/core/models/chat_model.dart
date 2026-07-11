import 'package:json_annotation/json_annotation.dart';
import 'package:quintou_app/core/models/user_model.dart';
import 'package:quintou_app/core/models/space_model.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class Conversation {
  final String id;
  final String bookingId;
  final String guestId;
  final String hostId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserSummary? guest;
  final UserSummary? host;
  final Message? lastMessage;

  Conversation({
    required this.id,
    required this.bookingId,
    required this.guestId,
    required this.hostId,
    required this.createdAt,
    required this.updatedAt,
    this.guest,
    this.host,
    this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);
}
