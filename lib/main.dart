import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zynotes/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:zynotes/constants/routes.dart';
import 'package:zynotes/views/login_view.dart';
import 'package:zynotes/views/register_view.dart';
import 'package:zynotes/views/user_guest_home.dart';
import 'package:zynotes/views/verify_email_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        homePage: (context) => const HomePage(),
        loginView: (context) => const LoginView(),
        registerView: (context) => const RegisterView(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 5, 140, 207)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

enum MenuAction { logout }

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.emailVerified) {
        return const UserHome();
      } else {
        return const VerifyEmail();
      }
    } else {
      return const GuestHome();
    }
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
