import 'package:flutter/material.dart';
import 'package:zynotes/services/auth/auth_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool darkThemeToggle = false;
  @override
  Widget build(BuildContext context) {
    final userEmail = AuthService.firebase().currentUser!.email;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            children: [
              Text(userEmail, style: const TextStyle(fontSize: 20)),
              Row(
                children: [
                  const Text('Dark Theme'),
                  IconButton(
                      icon: Icon(
                          darkThemeToggle ? Icons.toggle_on : Icons.toggle_off),
                      onPressed: () {
                        setState(() {
                          darkThemeToggle = !darkThemeToggle;
                        });
                      })
                ],
              )
            ],
          ),
        ));
  }
}
