import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListItem {
  final String id;
  final String bookId;
  final String bookTitle;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String lastMessageSenderId;
  /// uid -> last read message timestamp for that user.
  final Map<String, DateTime?> readBy;
  /// uid -> display name (set when chat is created / updated).
  final Map<String, String> displayNames;

  ChatListItem({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.participants,
    required this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId = '',
    this.readBy = const {},
    this.displayNames = const {},
  });

  factory ChatListItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final participantsList = data['participants'];
    final participants = participantsList is List
        ? List<String>.from(participantsList.map((e) => e.toString()))
        : <String>[];
    final lastMessageTime = data['lastMessageTime'] as Timestamp?;
    final rawReadBy = data['readBy'];
    final readBy = <String, DateTime?>{};
    if (rawReadBy is Map) {
      for (final e in rawReadBy.entries) {
        final key = e.key.toString();
        final value = e.value;
        if (value is Timestamp) {
          readBy[key] = value.toDate();
        } else {
          readBy[key] = null;
        }
      }
    }
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
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      readBy: readBy,
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

  bool hasUnreadForUser(String userId) {
    if (lastMessageSenderId.isEmpty || lastMessageSenderId == userId) {
      return false;
    }
    final lastTime = lastMessageTime;
    if (lastTime == null) return false;
    final readAt = readBy[userId];
    if (readAt == null) return true;
    return readAt.isBefore(lastTime);
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.latitude,
    this.longitude,
    required this.timestamp,
  });

  bool get hasLocation => latitude != null && longitude != null;

  factory ChatMessage.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['timestamp'] as Timestamp?;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      latitude: _toDouble(data['latitude']),
      longitude: _toDouble(data['longitude']),
      timestamp: ts?.toDate() ?? DateTime.now(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return null;
  }
}
