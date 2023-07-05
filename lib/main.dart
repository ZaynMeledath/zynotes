import 'package:flutter/material.dart';
import 'package:zynotes/constants/routes.dart';
import 'package:zynotes/views/login_view.dart';
import 'package:zynotes/views/register_view.dart';
import 'package:zynotes/views/verify_email_view.dart';
import 'package:zynotes/views/notes_view.dart';
import 'package:zynotes/views/guest_view.dart';
import 'package:zynotes/services/auth/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.firebase().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        homePage: (context) => const HomePage(),
        loginView: (context) => const LoginView(),
        registerView: (context) => const RegisterView(),
        verifyEmail: (context) => const VerifyEmail(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 5, 177, 207)),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(foregroundColor: Colors.white)),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.firebase().currentUser;
    if (user != null) {
      if (user.isEmailVerified) {
        return const NotesView();
      } else {
        return const VerifyEmail();
      }
    } else {
      return const GuestView();
    }
  }
}
