import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class FilterPills extends StatelessWidget {
  final String activeFilter;
  final Function(String) onFilterChanged;

  const FilterPills({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final List<Map<String, String>> _filters = const [
    {'id': 'all', 'label': 'All Books'},
    {'id': 'nearby', 'label': 'Nearby'},
    {'id': 'recent', 'label': 'Recent'},
    {'id': 'popular', 'label': 'Most Requested'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isActive = activeFilter == filter['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildFilterButton(
              label: filter['label']!,
              isActive: isActive,
              onTap: () => onFilterChanged(filter['id']!),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.badge),
            boxShadow: isActive ? null : AppShadows.sharpBase,
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isActive ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

