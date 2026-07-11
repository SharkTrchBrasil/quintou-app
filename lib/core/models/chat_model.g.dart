// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: json['id'] as String,
  conversationId: json['conversationId'] as String,
  senderId: json['senderId'] as String,
  content: json['content'] as String,
  isRead: json['isRead'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversationId': instance.conversationId,
  'senderId': instance.senderId,
  'content': instance.content,
  'isRead': instance.isRead,
  'createdAt': instance.createdAt.toIso8601String(),
};

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
  id: json['id'] as String,
  bookingId: json['bookingId'] as String,
  guestId: json['guestId'] as String,
  hostId: json['hostId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  guest: json['guest'] == null
      ? null
      : UserSummary.fromJson(json['guest'] as Map<String, dynamic>),
  host: json['host'] == null
      ? null
      : UserSummary.fromJson(json['host'] as Map<String, dynamic>),
  lastMessage: json['lastMessage'] == null
      ? null
      : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'guestId': instance.guestId,
      'hostId': instance.hostId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'guest': instance.guest,
      'host': instance.host,
      'lastMessage': instance.lastMessage,
    };
