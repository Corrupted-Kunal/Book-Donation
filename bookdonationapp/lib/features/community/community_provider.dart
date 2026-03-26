import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'community_service.dart';

final communityServiceProvider =
    Provider<CommunityService>((ref) => CommunityService());

final communityPostsProvider =
    StreamProvider<QuerySnapshot<Map<String, dynamic>>>((ref) {
  final service = ref.watch(communityServiceProvider);
  return service.streamPosts();
});

