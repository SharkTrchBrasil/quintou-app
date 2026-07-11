import 'package:quintou_app/core/api/api_client.dart';
import 'package:quintou_app/core/models/chat_model.dart';

class ChatRepository {
  final ApiClient _apiClient;

  ChatRepository(this._apiClient);

  Future<List<Conversation>> getConversations({int limit = 20, int offset = 0}) async {
    final response = await _apiClient.dio.get('/chat/conversations', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
    return (response.data as List).map((json) => Conversation.fromJson(json)).toList();
  }

  Future<List<Message>> getMessages(String conversationId, {int limit = 50, int offset = 0}) async {
    final response = await _apiClient.dio.get('/chat/conversations/$conversationId/messages', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
    return (response.data as List).map((json) => Message.fromJson(json)).toList();
  }

  Future<Message> sendMessage(String bookingId, String content) async {
    final response = await _apiClient.dio.post('/chat/conversations/$bookingId/messages', data: {
      'content': content,
    });
    return Message.fromJson(response.data);
  }
}
