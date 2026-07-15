import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/api/api_client.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final apiClient = ApiClient();
  return NotificationsRepository(apiClient);
});

class NotificationsRepository {
  final ApiClient _apiClient;
  
  NotificationsRepository(this._apiClient);
  
  Future<List<NotificationModel>> getNotifications({int limit = 20, int offset = 0}) async {
    final response = await _apiClient.dio.get(
      '/notifications',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data as List;
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }
  
  Future<void> markAsRead(String id) async {
    await _apiClient.dio.put('/notifications/$id/read');
  }
  
  Future<void> markAllAsRead() async {
    await _apiClient.dio.put('/notifications/read-all');
  }
  
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get('/notifications/unread-count');
      return response.data['unread_count'] as int;
    } catch (_) {
      return 0;
    }
  }
}

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  
  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    required this.createdAt,
  });
  
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      body: json['body'],
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  bool _hasMore = true;
  int _offset = 0;
  static const int _limit = 20;

  @override
  Future<List<NotificationModel>> build() async {
    _offset = 0;
    final repo = ref.watch(notificationsRepositoryProvider);
    final items = await repo.getNotifications(limit: _limit, offset: _offset);
    _hasMore = items.length >= _limit;
    return items;
  }
  
  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading || state.hasError) return;
    _offset += _limit;
    final repo = ref.read(notificationsRepositoryProvider);
    try {
      final newItems = await repo.getNotifications(limit: _limit, offset: _offset);
      _hasMore = newItems.length >= _limit;
      state = AsyncValue.data([...state.value ?? [], ...newItems]);
    } catch (e) {
      _offset -= _limit;
    }
  }
  
  Future<void> markAsRead(String id) async {
    if (state.value == null) return;
    final list = List<NotificationModel>.from(state.value!);
    final index = list.indexWhere((n) => n.id == id);
    if (index != -1 && !list[index].isRead) {
      final repo = ref.read(notificationsRepositoryProvider);
      await repo.markAsRead(id);
      
      list[index] = NotificationModel(
        id: list[index].id,
        type: list[index].type,
        title: list[index].title,
        body: list[index].body,
        data: list[index].data,
        isRead: true,
        createdAt: list[index].createdAt,
      );
      state = AsyncValue.data(list);
      ref.invalidate(unreadNotificationsCountProvider);
    }
  }
  
  Future<void> markAllAsRead() async {
    final repo = ref.read(notificationsRepositoryProvider);
    await repo.markAllAsRead();
    ref.invalidateSelf();
    ref.invalidate(unreadNotificationsCountProvider);
  }
}

final notificationsProvider = AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(() {
  return NotificationsNotifier();
});

final unreadNotificationsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  return await repo.getUnreadCount();
});
