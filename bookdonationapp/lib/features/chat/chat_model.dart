import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListItem {
  final String id;
  final String bookId;
  final String bookTitle;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageTime;
  /// uid -> display name (set when chat is created / updated).
  final Map<String, String> displayNames;

  ChatListItem({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.participants,
    required this.lastMessage,
    this.lastMessageTime,
    this.displayNames = const {},
  });

  factory ChatListItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final participantsList = data['participants'];
    final participants = participantsList is List
        ? List<String>.from(participantsList.map((e) => e.toString()))
        : <String>[];
    final lastMessageTime = data['lastMessageTime'] as Timestamp?;
    final rawNames = data['displayNames'];
    final displayNames = <String, String>{};
    if (rawNames is Map) {
      for (final e in rawNames.entries) {
        final v = e.value;
        if (v != null && v.toString().trim().isNotEmpty) {
          displayNames[e.key.toString()] = v.toString().trim();
        }
      }
    }
    return ChatListItem(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      participants: participants,
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: lastMessageTime?.toDate(),
      displayNames: displayNames,
    );
  }

  String otherParticipantId(String myUid) {
    return participants.firstWhere(
      (p) => p != myUid,
      orElse: () => myUid,
    );
  }

  /// Human-readable label for [otherParticipantId]; falls back to shortened uid.
  String otherParticipantLabel(String myUid) {
    final oid = otherParticipantId(myUid);
    final name = displayNames[oid];
    if (name != null && name.isNotEmpty) return name;
    if (oid.length > 8) return 'User ···${oid.substring(oid.length - 6)}';
    return oid.isEmpty ? 'User' : oid;
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
