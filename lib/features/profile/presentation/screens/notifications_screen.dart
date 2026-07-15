import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  IconData _getIconForType(String type) {
    switch (type) {
      case 'BOOKING_REQUEST':
      case 'BOOKING_CONFIRMED':
      case 'BOOKING_CANCELLED':
      case 'BOOKING_COMPLETED':
      case 'BOOKING_REMINDER':
      case 'HOST_REMINDER':
        return Icons.event;
      case 'REVIEW_RECEIVED':
      case 'REVIEW_REQUEST':
        return Icons.star;
      case 'PAYMENT_RECEIVED':
      case 'HOST_WEEKLY_SUMMARY':
        return Icons.attach_money;
      case 'NEW_MESSAGE':
      case 'MESSAGE_RECEIVED':
        return Icons.chat;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'BOOKING_CONFIRMED':
      case 'BOOKING_COMPLETED':
      case 'PAYMENT_RECEIVED':
        return Colors.green;
      case 'BOOKING_CANCELLED':
        return Colors.red;
      case 'REVIEW_RECEIVED':
      case 'REVIEW_REQUEST':
        return Colors.orange;
      case 'NEW_MESSAGE':
      case 'MESSAGE_RECEIVED':
        return const Color(0xFF00AEEF);
      default:
        return const Color(0xFF00AEEF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notificações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllAsRead();
            },
            child: const Text('Lidas', style: TextStyle(color: Color(0xFF00AEEF))),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma notificação por enquanto.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider);
              await ref.read(notificationsProvider.future);
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                  ref.read(notificationsProvider.notifier).loadMore();
                }
                return false;
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final isUnread = !notif.isRead;
                  
                  return InkWell(
                    onTap: () {
                      if (isUnread) {
                        ref.read(notificationsProvider.notifier).markAsRead(notif.id);
                      }
                    },
                    child: Container(
                      color: isUnread ? const Color(0xFFF0FBFF) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getColorForType(notif.type).withAlpha(25), // 0.1 opacity
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconForType(notif.type),
                              color: _getColorForType(notif.type),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif.title,
                                        style: TextStyle(
                                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${notif.createdAt.day}/${notif.createdAt.month}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notif.body,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isUnread ? Colors.black87 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isUnread)
                            Container(
                              margin: const EdgeInsets.only(left: 12, top: 4),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00AEEF),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00AEEF))),
        error: (err, stack) => Center(child: Text('Erro ao carregar: $err')),
      ),
    );
  }
}
