import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class SetLocationScreen extends StatelessWidget {
  const SetLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Set Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search city or address',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.my_location),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildLocationOption('Mumbai, Maharashtra'),
                  _buildLocationOption('Delhi, NCR'),
                  _buildLocationOption('Bangalore, Karnataka'),
                  _buildLocationOption('Pune, Maharashtra'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationOption(String location) {
    return ListTile(
      leading: const Icon(Icons.location_on),
      title: Text(location),
      onTap: () {
        // Set location
      },
    );
  }
}

