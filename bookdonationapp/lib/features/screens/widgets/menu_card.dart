import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'menu_item_row.dart';

class MenuCard extends StatelessWidget {
  const MenuCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.normalCard),
        boxShadow: AppShadows.sharpBase,
      ),
      child: Column(
        children: [
          MenuItemRow(
            icon: Icons.edit,
            label: 'Edit Profile',
            onTap: () {
              context.push('/edit-profile');
            },
          ),
          MenuItemRow(
            icon: Icons.workspace_premium,
            label: 'View Certificates',
            onTap: () {
              context.push('/rewards');
            },
          ),
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
        ],
      ),
    );
  }
}

