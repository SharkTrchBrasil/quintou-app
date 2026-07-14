import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quintou_app/features/chat/data/models/conversation_model.dart';
import 'package:quintou_app/features/chat/presentation/providers/chat_provider.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:quintou_app/core/providers/providers.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTypingMessage = false;
  MessagesController? _messagesController;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    _initChat();
  }

  void _initChat() {
    final repo = ref.read(featureChatRepositoryProvider);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Mark as read silently (may fail for brand new conversations)
      repo.markMessagesAsRead(widget.conversation.id).catchError((_) {});
      ref.invalidate(conversationsProvider);
    });
    
    _messagesController = MessagesController(
      repository: repo,
      conversationId: widget.conversation.id,
    );
    _messagesController!.addListener(_onMessagesChanged);
  }

  @override
  void dispose() {
    _messagesController?.removeListener(_onMessagesChanged);
    _messagesController?.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMessagesChanged() {
    if (mounted) setState(() {});
  }

  void _onTextChanged() {
    final text = _messageController.text;
    if (text.isNotEmpty && !_isTypingMessage) {
      setState(() => _isTypingMessage = true);
      _messagesController?.sendTypingIndicator();
    } else if (text.isEmpty && _isTypingMessage) {
      setState(() => _isTypingMessage = false);
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messagesController?.sendMessage(text);
    _messageController.clear();
    
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?.id;
    
    final typingAsync = ref.watch(typingStreamProvider(widget.conversation.id));
    final isTyping = typingAsync.value == widget.conversation.otherUser?.id;

    final otherUser = widget.conversation.otherUser;
    final userName = otherUser?.fullName ?? 'Usuário';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName, 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)
                  ),
                  Row(
                    children: [
                      Text(
                        'No Quintou desde 2024', 
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600)
                      ),
                      if (isTyping) ...[
                        const SizedBox(width: 8),
                        const Text('Digitando...', style: TextStyle(fontSize: 12, color: Color(0xFF00AEEF))),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner do Espaço
          InkWell(
            onTap: () async {
              try {
                BotToast.showLoading();
                final repo = ref.read(spaceRepositoryProvider);
                final space = await repo.getSpace(widget.conversation.spaceId);
                BotToast.closeAllLoading();
                if (mounted) {
                  context.push('/space-details', extra: space);
                }
              } catch (e) {
                BotToast.closeAllLoading();
                BotToast.showText(text: 'Erro ao abrir detalhes');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      image: widget.conversation.spaceImage != null && widget.conversation.spaceImage!.isNotEmpty
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(widget.conversation.spaceImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.conversation.spaceImage == null || widget.conversation.spaceImage!.isEmpty
                        ? const Icon(Icons.home, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.conversation.spaceTitle ?? 'Espaço',
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
          
          // Banner de Segurança
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF1E1E1E), // Preto
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'O Quintou não solicita seus dados ou envia links por este chat, nem por WhatsApp ou telefone.',
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de Mensagens
          Expanded(
            child: Builder(
              builder: (context) {
                if (!mounted || _messagesController == null) return const SizedBox();
                
                final controller = _messagesController!;

                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00AEEF)));
                }
                if (controller.error != null) {
                  return Center(child: Text('Erro: ${controller.error}'));
                }
                
                final messages = controller.messages;
                
                // Empty state
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma mensagem ainda',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Seja o primeiro a enviar uma mensagem!',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  );
                }
                
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    // Load more when scrolling up (towards older messages)
                    if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200 &&
                        !controller.isLoadingMore &&
                        controller.hasMore) {
                      controller.loadMoreMessages();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Começa do final
                    itemCount: messages.length + (controller.isLoadingMore ? 1 : 0),
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                    itemBuilder: (context, index) {
                      // Loading indicator at the end
                      if (index == messages.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(color: Color(0xFF00AEEF)),
                          ),
                        );
                      }
                      
                      final message = messages[index];
                      final isMe = message.senderId == currentUserId;
                    
                    // Lógica para mostrar Data Header (Hoje, Ontem, etc)
                    bool showDateHeader = false;
                    String dateHeaderText = '';
                    
                    if (index == messages.length - 1) {
                      showDateHeader = true;
                    } else {
                      final prevMessage = messages[index + 1];
                      final currentDay = DateTime(message.createdAt.year, message.createdAt.month, message.createdAt.day);
                      final prevDay = DateTime(prevMessage.createdAt.year, prevMessage.createdAt.month, prevMessage.createdAt.day);
                      if (currentDay.difference(prevDay).inDays > 0) {
                        showDateHeader = true;
                      }
                    }

                    if (showDateHeader) {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final msgDate = DateTime(message.createdAt.year, message.createdAt.month, message.createdAt.day);
                      final diff = today.difference(msgDate).inDays;
                      
                      if (diff == 0) dateHeaderText = 'Hoje';
                      else if (diff == 1) dateHeaderText = 'Ontem';
                      else dateHeaderText = '${msgDate.day}/${msgDate.month}/${msgDate.year}';
                    }

                    return Column(
                      children: [
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              dateHeaderText,
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFF00AEEF) : Colors.grey.shade200,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 16),
                              ),
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                (message.content.startsWith('http') && message.content.contains(RegExp(r'\.(jpg|jpeg|png|gif|webp)')))
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: message.content,
                                      width: 200,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                                    ),
                                  )
                                : Text(
                                    message.content,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        color: isMe ? Colors.white70 : Colors.grey.shade500,
                                        fontSize: 10,
                                      ),
                                    ),
                                    if (isMe) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.done_all, size: 12, color: Colors.white70),
                                    ]
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
              },
            ),
          ),
          
          // Action Buttons
          if (widget.conversation.hostId != currentUserId)
            Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      try {
                        BotToast.showLoading();
                        final repo = ref.read(spaceRepositoryProvider);
                        final space = await repo.getSpace(widget.conversation.spaceId);
                        BotToast.closeAllLoading();
                        if (mounted) {
                          context.push('/space-details', extra: space);
                        }
                      } catch (e) {
                        BotToast.closeAllLoading();
                        BotToast.showText(text: 'Erro ao abrir detalhes');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Ver Detalhes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AEEF), // Azul Quintou
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Agendar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
          
          // Barra de digitação
          Container(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Ícone de Anexo (+)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.grey, size: 28),
                    onPressed: () async {
                      try {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          BotToast.showLoading();
                          final repo = ref.read(featureChatRepositoryProvider);
                          final url = await repo.uploadImage(pickedFile.path);
                          _messagesController?.sendMessage(url);
                          BotToast.closeAllLoading();
                        }
                      } catch (e) {
                        BotToast.closeAllLoading();
                        BotToast.showText(text: 'Erro ao enviar imagem');
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Responder $userName',
                                hintStyle: TextStyle(color: Colors.grey.shade500),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                              maxLines: 4,
                              minLines: 1,
                            ),
                          ),
                          if (!_isTypingMessage)
                            IconButton(
                              icon: const Icon(Icons.mic_none, color: Colors.grey),
                              onPressed: () {},
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.send, color: Color(0xFF00AEEF)),
                              onPressed: _sendMessage,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}
