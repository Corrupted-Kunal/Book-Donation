import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

enum NavItem {
  home('/home'),
  donate('/donate'),
  requests('/requests'),
  chat('/chat'),
  profile('/profile');

  final String path;
  const NavItem(this.path);
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home,
                activeIcon: Icons.home,
                label: 'Home',
                item: NavItem.home,
                currentLocation: currentLocation,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.book,
                activeIcon: Icons.book,
                label: 'Donate',
                item: NavItem.donate,
                currentLocation: currentLocation,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.search,
                activeIcon: Icons.search,
                label: 'Requests',
                item: NavItem.requests,
                currentLocation: currentLocation,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.chat,
                activeIcon: Icons.chat,
                label: 'Chat',
                item: NavItem.chat,
                currentLocation: currentLocation,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person,
                activeIcon: Icons.person,
                label: 'Profile',
                item: NavItem.profile,
                currentLocation: currentLocation,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required NavItem item,
    required String currentLocation,
  }) {
    final isSelected = currentLocation == item.path;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(item.path),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Active indicator line
                  if (isSelected)
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 32,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  // Icon
                  Icon(
                    isSelected ? activeIcon : icon,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.textMuted,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color:
                      isSelected ? AppColors.primaryBlue : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
