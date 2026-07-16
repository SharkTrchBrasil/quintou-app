import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quintou_app/features/chat/presentation/providers/chat_provider.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:quintou_app/core/shell/app_shell.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quintou_app/core/widgets/login_required_placeholder.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (authState.user == null) {
      return const LoginRequiredPlaceholder(
        title: 'Mensagens',
        message: 'Faça login para ver suas mensagens',
        subMessage: 'Converse com anfitriões ou hóspedes sobre suas reservas.',
        icon: Icons.chat_bubble_outline,
      );
    }
    final conversationsAsync = ref.watch(conversationsProvider);
    final currentUserId = authState.user?.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de Chats
          Expanded(
            child: conversationsAsync.when(
              data: (conversations) {
                final isHostMode = ref.watch(isHostModeProvider);
                
                final filteredConversations = conversations.where((conv) {
                  if (currentUserId == null) return false;
                  return isHostMode 
                      ? conv.hostId == currentUserId 
                      : conv.guestId == currentUserId;
                }).toList();

                if (filteredConversations.isEmpty) {
                  return const Center(
                    child: Text(
                      'Você ainda não tem nenhuma conversa.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(conversationsProvider);
                    await ref.read(conversationsProvider.future);
                  },
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                        ref.read(conversationsProvider.notifier).loadMore();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemCount: filteredConversations.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      itemBuilder: (context, index) {
                      final conv = filteredConversations[index];
                      final bool hasUnread = conv.unreadCount > 0;
                      final otherUser = conv.otherUser;
                      final userName = otherUser?.fullName ?? 'Usuário desconhecido';
                      
                      String timeString = '';
                      if (conv.lastMessageAt != null) {
                        final now = DateTime.now();
                        final diff = now.difference(conv.lastMessageAt!);
                        if (diff.inDays == 0) {
                          timeString = '${conv.lastMessageAt!.hour.toString().padLeft(2, '0')}:${conv.lastMessageAt!.minute.toString().padLeft(2, '0')}';
                        } else if (diff.inDays < 7) {
                          timeString = '${diff.inDays} d';
                        } else {
                          timeString = '${conv.lastMessageAt!.day}/${conv.lastMessageAt!.month}';
                        }
                      }

                      return InkWell(
                        onTap: () {
                          context.push('/chat/${conv.id}', extra: conv);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Imagem do Espaço com Avatar sobreposto
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                      image: conv.spaceImage != null && conv.spaceImage!.isNotEmpty
                                          ? DecorationImage(
                                              image: CachedNetworkImageProvider(conv.spaceImage!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: conv.spaceImage == null || conv.spaceImage!.isEmpty
                                        ? const Icon(Icons.home, color: Colors.grey)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: -6,
                                    right: -6,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.grey.shade300,
                                        backgroundImage: otherUser?.avatarUrl != null 
                                            ? CachedNetworkImageProvider(otherUser!.avatarUrl!) 
                                            : null,
                                        child: otherUser?.avatarUrl == null 
                                            ? Text(userName[0].toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.black87)) 
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              
                              // Textos
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            conv.spaceTitle ?? 'Espaço',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          timeString,
                                          style: TextStyle(
                                            color: hasUnread ? const Color(0xFF00AEEF) : Colors.grey.shade500,
                                            fontSize: 12,
                                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          userName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified, color: Color(0xFF00AEEF), size: 14),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        // Ícone de check de mensagem lida/enviada
                                        Icon(
                                          Icons.done_all, 
                                          size: 16, 
                                          color: hasUnread ? Colors.grey : const Color(0xFF00AEEF)
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            conv.lastMessage ?? 'Inicie a conversa',
                                            style: TextStyle(
                                              color: hasUnread ? Colors.black87 : Colors.grey.shade600,
                                              fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (hasUnread)
                                          Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF00AEEF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              conv.unreadCount.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
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
              error: (error, stackTrace) => Center(
                child: Text('Erro ao carregar chats: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
