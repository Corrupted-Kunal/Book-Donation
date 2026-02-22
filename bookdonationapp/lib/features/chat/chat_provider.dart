import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_service.dart';
import 'chat_model.dart';

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final userChatsStreamProvider =
    StreamProvider.autoDispose.family<List<ChatListItem>, String>((ref, userId) {
  final service = ref.watch(chatServiceProvider);
  return service.streamChatsForUser(userId);
});

final chatMessagesStreamProvider =
    StreamProvider.autoDispose.family<List<ChatMessage>, String>((ref, chatId) {
  final service = ref.watch(chatServiceProvider);
  return service.streamMessages(chatId);
});
