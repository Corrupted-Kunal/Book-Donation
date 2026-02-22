import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_model.dart';

class ChatService {
  final _chats = FirebaseFirestore.instance.collection('chats');

  /// Creates or reuses a chat. documentId = bookId + "_" + requesterId.
  /// Returns the chat document id.
  Future<String> createOrGetChat({
    required String bookId,
    required String ownerId,
    required String requesterId,
    required String bookTitle,
  }) async {
    final chatId = '${bookId}_$requesterId';
    final doc = _chats.doc(chatId);
    final snapshot = await doc.get();

    if (snapshot.exists) {
      return chatId;
    }

    await doc.set({
      'bookId': bookId,
      'bookTitle': bookTitle,
      'participants': [ownerId, requesterId],
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return chatId;
  }

  Stream<List<ChatListItem>> streamChatsForUser(String userId) {
    return _chats
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatListItem.fromDoc(d)).toList());
  }

  Stream<List<ChatMessage>> streamMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatMessage.fromDoc(d)).toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final messagesRef = _chats.doc(chatId).collection('messages');
    await messagesRef.add({
      'senderId': senderId,
      'text': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    await _chats.doc(chatId).update({
      'lastMessage': text.trim(),
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }
}
