import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zynotes/constants/routes.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // if (user?.emailVerified ?? false) {
    //   return const HomePage();
    // }
    return Scaffold(
        appBar: AppBar(title: const Text('Verify Email'), centerTitle: true),
        body: Column(
          children: [
            const Text('Click to verify'),
            ElevatedButton(
                onPressed: () {
                  if (user == null) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginview, (route) => false);
                  } else if (!user.emailVerified) {
                    user.sendEmailVerification();
                  }
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginview, (route) => false);
                },
                child: const Text('Login and verify')),
          ],
        ));
  }
}
