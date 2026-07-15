import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quintou_app/core/api/api_client.dart';
import 'package:quintou_app/features/chat/data/models/conversation_model.dart';
import 'package:quintou_app/features/chat/data/models/message_model.dart';
import 'package:quintou_app/features/chat/data/repositories/chat_repository.dart';
import 'package:quintou_app/features/chat/data/services/websocket_service.dart';

final featureChatRepositoryProvider = Provider<ChatRepository>((ref) {
  final apiClient = ApiClient();
  return ChatRepository(apiClient);
});

class ConversationsNotifier extends AsyncNotifier<List<Conversation>> {
  int _offset = 0;
  bool _hasMore = true;
  static const int _limit = 20;
  StreamSubscription? _wsSub;

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
    
    // 3. Connect to global WebSocket to receive real-time updates
    final wsService = WebSocketService();
    wsService.connect();
    
    // Listen to new messages to update the inbox
    _wsSub?.cancel();
    _wsSub = wsService.messageStream.listen((message) {
      _handleNewMessage(message);
    });
    
    ref.onDispose(() {
      _wsSub?.cancel();
    });
    
    return conversations;
  }
  
  void _handleNewMessage(ChatMessage message) {
    if (state.value == null) return;
    
    final currentList = List<Conversation>.from(state.value!);
    final index = currentList.indexWhere((c) => c.id == message.conversationId);
    
    if (index != -1) {
      // Update existing conversation — reconstruct with updated fields
      final conv = currentList[index];
      final updatedConv = Conversation(
        id: conv.id,
        bookingId: conv.bookingId,
        spaceId: conv.spaceId,
        hostId: conv.hostId,
        guestId: conv.guestId,
        createdAt: conv.createdAt,
        spaceTitle: conv.spaceTitle,
        spaceImage: conv.spaceImage,
        otherUser: conv.otherUser,
        lastMessage: message.content,
        lastMessageAt: message.createdAt,
        unreadCount: conv.unreadCount + 1,
      );
      
      currentList.removeAt(index);
      currentList.insert(0, updatedConv);
      state = AsyncValue.data(currentList);
    } else {
      // New conversation — invalidate to fetch from server
      ref.invalidateSelf();
    }
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

final conversationsProvider = AsyncNotifierProvider<ConversationsNotifier, List<Conversation>>(() {
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
  String? typingUserId;
  Timer? _typingTimer;
  StreamSubscription? _msgSub;
  StreamSubscription? _typingSub;
  
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

      _wsService = WebSocketService();
      _wsService.connect(); // Connects if not already connected (singleton)
      
      _msgSub = _wsService.messageStream.listen((newMessage) {
        if (_disposed || newMessage.conversationId != conversationId) return;
        
        // Check if message already exists (to avoid duplicates from WebSocket + HTTP)
        if (!messages.any((m) => m.id == newMessage.id)) {
          messages = [newMessage, ...messages];
          notifyListeners();
        }
      });
      
      _typingSub = _wsService.typingStream.listen((event) {
        if (_disposed || event['conversation_id'] != conversationId) return;
        typingUserId = event['user_id'];
        notifyListeners();
        
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(seconds: 3), () {
          if (!_disposed) {
            typingUserId = null;
            notifyListeners();
          }
        });
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
      // Send via WS to trigger push notifications and real-time broadcast
      _wsService.sendMessage(conversationId, content);
      
      // Also send via HTTP for persistence guarantee
      final msg = await repository.sendMessage(conversationId, content);
      if (_disposed) return;
      if (!messages.any((m) => m.id == msg.id)) {
        messages = [msg, ...messages];
        notifyListeners();
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void sendTypingIndicator() {
    _wsService.sendTypingIndicator(conversationId);
  }

  @override
  void dispose() {
    _disposed = true;
    _typingTimer?.cancel();
    _msgSub?.cancel();
    _typingSub?.cancel();
    super.dispose();
  }
}
