import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/auth_provider.dart';
import '../chat/chat_provider.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  String? _lastMarkedForUser;
  bool _isMarkingAllRead = false;

  String _formatTimestamp(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return DateFormat.Hm().format(date);
    }
    if (date.year == now.year) {
      return DateFormat.MMMd().format(date);
    }
    return DateFormat.yMMMd().format(date);
  }

  Future<void> _markAllReadIfNeeded(String userId) async {
    if (_isMarkingAllRead || _lastMarkedForUser == userId) return;
    _isMarkingAllRead = true;
    _lastMarkedForUser = userId;
    try {
      await ref.read(chatServiceProvider).markAllChatsAsRead(userId);
    } catch (_) {
      // Ignore failures here; unread indicator will retry next visit.
    } finally {
      _isMarkingAllRead = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authStateProvider).value;

    if (authUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Chat',
            style: AppTextStyles.heading2,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            'Sign in to see your conversations.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    final chatsAsync = ref.watch(userChatsStreamProvider(authUser.uid));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _markAllReadIfNeeded(authUser.uid);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Chat',
          style: AppTextStyles.heading2,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Request a book to start a conversation',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherLabel = chat.otherParticipantLabel(authUser.uid);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                  child: Text(
                    (otherLabel.isNotEmpty ? otherLabel[0] : '?').toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  otherLabel,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  chat.bookTitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  _formatTimestamp(chat.lastMessageTime),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                onTap: () async {
                  await ref.read(chatServiceProvider).markChatAsRead(
                        chatId: chat.id,
                        userId: authUser.uid,
                      );
                  context.push('/chat/${chat.id}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load chats: $err',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.destructiveRed,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
