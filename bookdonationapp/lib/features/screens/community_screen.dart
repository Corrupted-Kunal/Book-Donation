import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/auth_provider.dart';
import '../community/community_provider.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final date = ts.toDate();
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return DateFormat.Hm().format(date);
    }
    if (date.year == now.year) {
      return DateFormat.MMMd().format(date);
    }
    return DateFormat.yMMMd().format(date);
  }

  Future<void> _handlePost() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign in to post in the community.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final service = ref.read(communityServiceProvider);
    try {
      await service.addPost(
        text: text,
        userId: user.uid,
        userEmail: user.email,
      );
      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(communityPostsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Community'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: AppColors.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.normalCard),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: 3,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Share something with the community...',
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _handlePost,
                        child: const Text('Post'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: postsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Failed to load community feed.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              data: (snapshot) {
                if (snapshot.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No posts yet. Be the first to share!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.docs[index];
                    final data = doc.data();
                    final email = (data['userEmail'] as String?) ?? 'Anonymous';
                    final text = (data['text'] as String?) ?? '';
                    final createdAt = data['createdAt'] as Timestamp?;

                    return Card(
                      color: AppColors.cardBg,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.normalCard),
                      ),
                      child: ListTile(
                        title: Text(
                          email.isEmpty ? 'Anonymous' : email,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              text,
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(createdAt),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

