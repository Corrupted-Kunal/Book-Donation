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
    String? ownerDisplayName,
    String? requesterDisplayName,
  }) async {
    final chatId = '${bookId}_$requesterId';
    final doc = _chats.doc(chatId);
    final snapshot = await doc.get();

    final names = <String, String>{};
    if (ownerDisplayName != null && ownerDisplayName.trim().isNotEmpty) {
      names[ownerId] = ownerDisplayName.trim();
    }
    if (requesterDisplayName != null && requesterDisplayName.trim().isNotEmpty) {
      names[requesterId] = requesterDisplayName.trim();
    }

    if (snapshot.exists) {
      if (names.isNotEmpty) {
        final data = snapshot.data() ?? {};
        final existingRaw = data['displayNames'];
        final merged = <String, String>{};
        if (existingRaw is Map) {
          for (final e in existingRaw.entries) {
            final v = e.value;
            if (v != null && v.toString().trim().isNotEmpty) {
              merged[e.key.toString()] = v.toString().trim();
            }
          }
        }
        merged.addAll(names);
        await doc.update({'displayNames': merged});
      }
      return chatId;
    }

    await doc.set({
      'bookId': bookId,
      'bookTitle': bookTitle,
      'participants': [ownerId, requesterId],
      'lastMessage': '',
      'lastMessageSenderId': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'readBy': {
        ownerId: FieldValue.serverTimestamp(),
        requesterId: FieldValue.serverTimestamp(),
      },
      if (names.isNotEmpty) 'displayNames': names,
    });

    return chatId;
  }

  /// Live chat document for app bar metadata (book title, participant labels).
  Stream<ChatListItem?> streamChatById(String chatId) {
    return _chats.doc(chatId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return ChatListItem.fromDoc(snap);
    });
  }

  Stream<List<ChatListItem>> streamChatsForUser(String userId) {
    return _chats
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snap) {
      final chats = snap.docs.map(ChatListItem.fromDoc).toList();
      chats.sort(
        (a, b) => (b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0)),
      );
      return chats;
    });
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
    double? latitude,
    double? longitude,
  }) async {
    final hasLocation = latitude != null && longitude != null;
    final normalizedText = text.trim();
    final messagePreview = hasLocation
        ? (normalizedText.isEmpty ? 'Shared location' : normalizedText)
        : normalizedText;
    final messagesRef = _chats.doc(chatId).collection('messages');
    await messagesRef.add({
      'senderId': senderId,
      'text': normalizedText,
      if (hasLocation) 'latitude': latitude,
      if (hasLocation) 'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await _chats.doc(chatId).update({
      'lastMessage': messagePreview,
      'lastMessageSenderId': senderId,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'readBy.$senderId': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markChatAsRead({
    required String chatId,
    required String userId,
  }) async {
    await _chats.doc(chatId).update({
      'readBy.$userId': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAllChatsAsRead(String userId) async {
    final snap = await _chats.where('participants', arrayContains: userId).get();
    final batch = FirebaseFirestore.instance.batch();
    final readAt = FieldValue.serverTimestamp();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'readBy.$userId': readAt});
    }
    await batch.commit();
  }
}
