import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/menu_item_row.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(AppRadius.normalCard),
                boxShadow: AppShadows.sharpBase,
              ),
              child: Column(
                children: [
                  MenuItemRow(
                    icon: Icons.language,
                    label: 'Language Settings',
                    badge: 'English',
                    onTap: () {
                      context.push('/language-settings');
                    },
                  ),
                  MenuItemRow(
                    icon: Icons.mic,
                    label: 'Voice Assistant',
                    onTap: () {
                      context.push('/voice-settings');
                    },
                  ),
                  MenuItemRow(
                    icon: Icons.location_on,
                    label: 'Location Settings',
                    onTap: () {
                      context.push('/location-settings');
                    },
                  ),
                  MenuItemRow(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification settings coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

