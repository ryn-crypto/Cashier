import 'package:cashier/assets/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customColorScheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: customColorScheme.surface,
        foregroundColor: customColorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
          // Left Column: Profile Information
          Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    'https://avatars.githubusercontent.com/u/76616223?v=4'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Riyan First Tiyanto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'riyandotianto2@gmail.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Edit profile action
                },
                icon: const Icon(Icons.edit, color: Colors.black54),
                label: const Text('Edit Profile',
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: customColorScheme.secondary,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Logout action
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Logout',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: customColorScheme.primary,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Right Column: Profile Details
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: customColorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text(
              'Profile Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            buildDetailRow('Username', 'Riyan First Tiyanto'),
            buildDetailRow('Email', 'riyandotianto2@gmail.com'),
            buildDetailRow('Phone', '+62 812 3456 7890'),
            buildDetailRow('Address', 'Jl. Example No. 123, Jakarta'),
            const SizedBox(height: 16),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                const url = 'https://ryn-crypto.github.io/';
                await launchUrl(
                    Uri.parse(url), mode: LaunchMode.externalApplication);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                'View More Details',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),]
    ,
    )
    ,
    )
    ,
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
