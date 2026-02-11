import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            subtitle: Text('Manage your profile'),
            onTap: () {
              // Navigate to profile screen
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            subtitle: Text('Configure alerts and notifications'),
            onTap: () {
              // Navigate to notifications settings
            },
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text('Change app language'),
            onTap: () {
              // Show language picker
            },
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Theme'),
            subtitle: Text('Light / Dark mode'),
            onTap: () {
              // Toggle theme
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Smart Irrigation',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Climate-Responsive IoT Irrigation',
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await _authService.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}
