import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListItem {
  final String id;
  final String bookId;
  final String bookTitle;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageTime;

  ChatListItem({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.participants,
    required this.lastMessage,
    this.lastMessageTime,
  });

  factory ChatListItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final participantsList = data['participants'];
    final participants = participantsList is List
        ? List<String>.from(participantsList.map((e) => e.toString()))
        : <String>[];
    final lastMessageTime = data['lastMessageTime'] as Timestamp?;
    return ChatListItem(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      participants: participants,
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: lastMessageTime?.toDate(),
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['timestamp'] as Timestamp?;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: ts?.toDate() ?? DateTime.now(),
    );
  }
}
