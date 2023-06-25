import 'package:zynotes/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:zynotes/constants/routes.dart';
import 'package:zynotes/enums/menu_action.dart';

class GuestHome extends StatefulWidget {
  const GuestHome({super.key});

  @override
  State<GuestHome> createState() => _GuestHomeState();
}

class _GuestHomeState extends State<GuestHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 14, 166, 241),
          title: const Text('Home Page'),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: Center(
            child: Column(
              children: [
                const Text('Hi Guest'),
                const Text('WELCOME TO ZYNOTES'),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginView, (route) => false);
                    },
                    child: const Text('Login or Register'))
              ],
            ),
          ),
        ));
  }
}

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.firebase().currentUser;
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
                Text('Hi ${user?.email}'),
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
