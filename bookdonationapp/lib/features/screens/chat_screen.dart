import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../ui/pieces/location_attachment_map_view.dart';
import '../../ui/screens/map_view.dart';
import '../auth/auth_provider.dart';
import '../chat/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatScreen({
    super.key,
    required this.chatId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  String? _markedReadForUser;

  Future<void> _markChatReadIfNeeded(String userId) async {
    if (_markedReadForUser == userId) return;
    _markedReadForUser = userId;
    try {
      await ref.read(chatServiceProvider).markChatAsRead(
            chatId: widget.chatId,
            userId: userId,
          );
    } catch (_) {
      // Ignore transient failures; it will be retried on next open.
      _markedReadForUser = null;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    _textController.clear();

    try {
      final chatService = ref.read(chatServiceProvider);
      await chatService.sendMessage(
        chatId: widget.chatId,
        senderId: user.uid,
        text: text,
      );
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickAndSendLocation() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final result = await Navigator.of(context).push<LocationPickResult>(
      MaterialPageRoute(builder: (_) => const MapViewScreen()),
    );
    if (result == null) return;

    try {
      final chatService = ref.read(chatServiceProvider);
      await chatService.sendMessage(
        chatId: widget.chatId,
        senderId: user.uid,
        text: result.caption ?? '',
        latitude: result.latitude,
        longitude: result.longitude,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send location: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;
    final messagesAsync = ref.watch(chatMessagesStreamProvider(widget.chatId));
    final chatDocAsync = ref.watch(chatByIdStreamProvider(widget.chatId));

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text('Sign in to chat')),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _markChatReadIfNeeded(currentUser.uid);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/chat'),
        ),
        title: chatDocAsync.when(
          data: (chat) {
            if (chat == null) {
              return Text('Chat', style: AppTextStyles.heading2);
            }
            final bookLine =
                chat.bookTitle.trim().isEmpty ? 'Chat' : chat.bookTitle;
            final who = chat.otherParticipantLabel(currentUser.uid);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  bookLine,
                  style: AppTextStyles.heading2.copyWith(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  who,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
          loading: () => Text('Chat', style: AppTextStyles.heading2),
          error: (_, __) => Text('Chat', style: AppTextStyles.heading2),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Say hello!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.background,
                        AppColors.mutedBg.withValues(alpha: 0.4),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUser.uid;
                      return _MessageBubble(
                        text: msg.text,
                        isMe: isMe,
                        latitude: msg.latitude,
                        longitude: msg.longitude,
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load messages: $err',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.destructiveRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Share current location',
                    onPressed: _pickAndSendLocation,
                    icon: const Icon(Icons.location_on),
                    color: AppColors.primaryBlue,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      style: AppTextStyles.bodyMedium,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
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

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final double? latitude;
  final double? longitude;

  const _MessageBubble({
    required this.text,
    required this.isMe,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = latitude != null && longitude != null;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: hasLocation
            ? const EdgeInsets.all(8)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasLocation)
              LocationAttachmentMapView(
                latitude: latitude!,
                longitude: longitude!,
                height: 140,
              ),
            if (text.trim().isNotEmpty) ...[
              if (hasLocation) const SizedBox(height: 8),
              Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
