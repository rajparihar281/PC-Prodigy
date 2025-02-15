import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _supabase = Supabase.instance.client;
  Future<void> _logout() async {
    try {
      await _supabase.auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      // _showError('Logout failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SETTINGS"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ListTile(title: Text("INFO"), trailing: Icon(Icons.arrow_forward_ios)),
          ListTile(
            title: Text("Logout"),
            trailing: Icon(Icons.logout_outlined),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
