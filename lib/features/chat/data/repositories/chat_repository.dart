import 'package:dio/dio.dart';
import 'package:quintou_app/core/api/api_client.dart';
import 'package:quintou_app/features/chat/data/models/conversation_model.dart';
import 'package:quintou_app/features/chat/data/models/message_model.dart';

class ChatRepository {
  final ApiClient _apiClient;

  ChatRepository(this._apiClient);

  Future<List<Conversation>> getConversations({int limit = 20, int offset = 0}) async {
    try {
      final response = await _apiClient.dio.get(
        '/conversations',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final List<dynamic> data = response.data;
      return data.map((e) => Conversation.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load conversations: $e');
    }
  }

  Future<Conversation> startConversationBySpace(String spaceId) async {
    try {
      final response = await _apiClient.dio.post(
        '/conversations',
        data: {'space_id': spaceId},
      );
      return Conversation.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to start conversation: $e');
    }
  }

  Future<List<ChatMessage>> getMessages(String conversationId, {int limit = 50, int offset = 0}) async {
    try {
      final response = await _apiClient.dio.get(
        '/conversations/$conversationId/messages',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final List<dynamic> data = response.data;
      return data.map((e) => ChatMessage.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  Future<ChatMessage> sendMessage(String conversationId, String content) async {
    try {
      final response = await _apiClient.dio.post(
        '/conversations/$conversationId/messages',
        data: {'content': content},
      );
      return ChatMessage.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      await _apiClient.dio.put('/conversations/$conversationId/read');
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  Future<int> getTotalUnread() async {
    try {
      final response = await _apiClient.dio.get('/conversations/unread-total');
      return response.data['unread_total'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<String> uploadImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
      });
      final response = await _apiClient.dio.post(
        '/upload/image',
        data: formData,
      );
      return response.data['url'];
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
