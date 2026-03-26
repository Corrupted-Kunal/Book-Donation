import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/auth_provider.dart';
import '../auth/user_firestore_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
    }
  }

  Future<void> _saveProfile() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await user.updateDisplayName(name);
      await user.reload();
      final fresh = FirebaseAuth.instance.currentUser;
      if (fresh != null) {
        await ref.read(userFirestoreServiceProvider).upsertFromAuth(fresh);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
                  child: Text(
                    (user?.displayName?.substring(0, 1) ??
                            user?.email?.substring(0, 1) ??
                            '?')
                        .toUpperCase(),
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Basic Information',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 12),
              Card(
                color: AppColors.cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.normalCard),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Your name',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)),
                          ),
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Email',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: TextEditingController(
                          text: user?.email ?? '',
                        ),
                        enabled: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)),
                          ),
                          filled: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'About',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 12),
              Card(
                color: AppColors.cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.normalCard),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Tell others a bit about yourself (optional)',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      filled: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

