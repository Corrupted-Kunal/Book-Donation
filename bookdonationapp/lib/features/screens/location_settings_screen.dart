import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LocationSettingsScreen extends StatelessWidget {
  const LocationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Location Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Location Preferences',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Enable Location Services'),
            subtitle: const Text('Allow app to access your location'),
            value: true,
            onChanged: (value) {},
          ),
          const Divider(),
          ListTile(
            title: const Text('Set Location'),
            subtitle: const Text('Mumbai, Maharashtra'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/set-location');
            },
          ),
        ],
      ),
    );
  }
}

