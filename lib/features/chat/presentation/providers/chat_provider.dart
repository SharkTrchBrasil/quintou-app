import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/api/api_client.dart';
import 'package:quintou_app/features/chat/data/models/conversation_model.dart';
import 'package:quintou_app/features/chat/data/models/message_model.dart';
import 'package:quintou_app/features/chat/data/repositories/chat_repository.dart';
import 'package:quintou_app/features/chat/data/services/websocket_service.dart';

final featureChatRepositoryProvider = Provider<ChatRepository>((ref) {
  final apiClient = ApiClient();
  return ChatRepository(apiClient);
});

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class ConversationsNotifier extends AutoDisposeAsyncNotifier<List<Conversation>> {
  int _offset = 0;
  bool _hasMore = true;
  static const int _limit = 20;

  @override
  Future<List<Conversation>> build() async {
    final repository = ref.watch(featureChatRepositoryProvider);
    final box = Hive.box('chat_cache');
    
    // 1. Emit Cache
    final cachedData = box.get('all_conversations');
    if (cachedData != null) {
      try {
        final List items = jsonDecode(cachedData);
        state = AsyncValue.data(items.map((e) => Conversation.fromJson(e)).toList());
      } catch (_) {}
    }
    
    // 2. Fetch Network
    _offset = 0;
    final conversations = await repository.getConversations(limit: _limit, offset: _offset);
    _hasMore = conversations.length >= _limit;
    await box.put('all_conversations', jsonEncode(conversations.map((e) => e.toJson()).toList()));
    return conversations;
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    _offset += _limit;
    try {
      final repository = ref.read(featureChatRepositoryProvider);
      final newConversations = await repository.getConversations(limit: _limit, offset: _offset);
      _hasMore = newConversations.length >= _limit;
      state = AsyncValue.data([...state.value ?? [], ...newConversations]);
    } catch (e) {
      _offset -= _limit;
    }
  }
}

final conversationsProvider = AsyncNotifierProvider.autoDispose<ConversationsNotifier, List<Conversation>>(() {
  return ConversationsNotifier();
});

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.watch(featureChatRepositoryProvider);
  return repository.getTotalUnread();
});

class MessagesController extends ChangeNotifier {
  final ChatRepository repository;
  final String conversationId;
  late WebSocketService _wsService;
  bool _disposed = false;

  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? error;
  List<ChatMessage> messages = [];
  
  static const int _pageSize = 50;
  int _currentOffset = 0;

  MessagesController({required this.repository, required this.conversationId}) {
    _init();
  }

  Future<void> _init() async {
    try {
      await loadMessages();
      if (_disposed) return;
      isLoading = false;
      notifyListeners();

      _wsService = WebSocketService(conversationId: conversationId);
      _wsService.connect();
      
      _wsService.messageStream.listen((newMessage) {
        if (_disposed) return;
        // Check if message already exists (to avoid duplicates from WebSocket + HTTP)
        if (!messages.any((m) => m.id == newMessage.id)) {
          messages = [newMessage, ...messages];
          notifyListeners();
        }
      });
    } catch (e, st) {
      if (_disposed) return;
      error = e.toString();
      isLoading = false;
      notifyListeners();
      print('Error initializing messages: $e\n$st');
    }
  }

  Future<void> loadMessages() async {
    try {
      final newMessages = await repository.getMessages(
        conversationId,
        limit: _pageSize,
        offset: _currentOffset,
      );
      
      if (_disposed) return;
      
      if (newMessages.length < _pageSize) {
        hasMore = false;
      }
      
      messages.addAll(newMessages);
      _currentOffset += newMessages.length;
      
      notifyListeners();
    } catch (e) {
      print('Error loading messages: $e');
      rethrow;
    }
  }

  Future<void> loadMoreMessages() async {
    if (isLoadingMore || !hasMore) return;
    
    isLoadingMore = true;
    notifyListeners();
    
    try {
      await loadMessages();
    } catch (e) {
      print('Error loading more messages: $e');
    } finally {
      if (!_disposed) {
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      final msg = await repository.sendMessage(conversationId, content);
      if (_disposed) return;
      if (!messages.any((m) => m.id == msg.id)) {
        messages = [msg, ...messages];
        notifyListeners();
      }
    } catch (e) {
      print('Error sending message: $e');
      // Handle error - could show toast to user
    }
  }

  void sendTypingIndicator() {
    _wsService.sendTypingIndicator();
  }

  @override
  void dispose() {
    _disposed = true;
    _wsService.dispose();
    super.dispose();
  }
}

// Provides the typing stream for a specific conversation
final typingStreamProvider = StreamProvider.autoDispose.family<String, String>((ref, conversationId) {
  final wsService = WebSocketService(conversationId: conversationId);
  wsService.connect();
  ref.onDispose(() => wsService.dispose());
  return wsService.typingStream;
});
