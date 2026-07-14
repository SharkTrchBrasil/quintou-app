class Conversation {
  final String id;
  final String? bookingId;
  final String spaceId;
  final String hostId;
  final String guestId;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final String? spaceTitle;
  final String? spaceImage;
  final String? lastMessage;
  final ChatUser? otherUser;
  final int unreadCount;

  Conversation({
    required this.id,
    this.bookingId,
    required this.spaceId,
    required this.hostId,
    required this.guestId,
    this.lastMessageAt,
    required this.createdAt,
    this.spaceTitle,
    this.spaceImage,
    this.lastMessage,
    this.otherUser,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    try {
      return Conversation(
        id: json['id'],
        bookingId: json['bookingId'] ?? json['booking_id'],
        spaceId: json['spaceId'] ?? json['space_id'],
        hostId: json['hostId'] ?? json['host_id'],
        guestId: json['guestId'] ?? json['guest_id'],
        lastMessageAt: (json['lastMessageAt'] ?? json['last_message_at']) != null ? DateTime.parse(json['lastMessageAt'] ?? json['last_message_at']) : null,
        createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
        spaceTitle: json['spaceTitle'] ?? json['space_title'],
        spaceImage: json['spaceImage'] ?? json['space_image'],
        lastMessage: json['lastMessage'] ?? json['last_message'],
        otherUser: (json['otherUser'] ?? json['other_user']) != null ? ChatUser.fromJson(json['otherUser'] ?? json['other_user']) : null,
        unreadCount: json['unreadCount'] ?? json['unread_count'] ?? 0,
      );
    } catch (e) {
      print('DEBUG PARSE ERROR: $e');
      print('DEBUG JSON DATA: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'space_id': spaceId,
      'host_id': hostId,
      'guest_id': guestId,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'space_title': spaceTitle,
      'space_image': spaceImage,
      'last_message': lastMessage,
      'other_user': otherUser?.toJson(),
      'unread_count': unreadCount,
    };
  }
}

class ChatUser {
  final String id;
  final String fullName;
  final String? avatarUrl;

  ChatUser({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      fullName: json['full_name'] ?? json['fullName'], // Handle both just in case
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
    };
  }
}
