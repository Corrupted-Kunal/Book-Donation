import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityService {
  final CollectionReference<Map<String, dynamic>> _posts =
      FirebaseFirestore.instance.collection('community_posts');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPosts() {
    return _posts.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addPost({
    required String text,
    required String userId,
    required String? userEmail,
  }) async {
    if (text.trim().isEmpty) return;

    await _posts.add({
      'userId': userId,
      'userEmail': userEmail,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

