import 'package:zynotes/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:zynotes/constants/routes.dart';
import 'package:zynotes/enums/menu_action.dart';

//USER HOME VIEW

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 14, 166, 241),
            title: const Text('Home Page'),
            centerTitle: true,
            actions: [
              PopupMenuButton<MenuAction>(itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                      value: MenuAction.logout, child: Text('Log Out'))
                ];
              }, onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogoutDialog(context);
                    if (shouldLogout) {
                      showDialog(
                        context: context,
                        builder: (context) => const CircularProgressIndicator(),
                      );
                      await AuthService.firebase().signOut();
                      Navigator.of(context).pop();
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginView, (route) => false);
                    }
                }
              })
            ]),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: Center(
            child: Column(
              children: [
                Text('Hi $userEmail'),
                const Text('WELCOME TO ZYNOTES'),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(loginView);
                    },
                    child: const Text('Login to another account'))
              ],
            ),
          ),
        ));
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      }).then((value) => value ?? false);
}
