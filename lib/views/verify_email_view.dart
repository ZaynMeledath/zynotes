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
        body: Center(
          child: Column(
            children: [
              Text('Click to verify your email ${user?.email}'),
              ElevatedButton(
                  onPressed: () {
                    if (user == null) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginView, (route) => false);
                    } else if (!user.emailVerified) {
                      user.sendEmailVerification();
                    }
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginView, (route) => false);
                  },
                  child: const Text('Verify')),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginView, (route) => false);
                },
                child: const Text('Login to another account'),
              )
            ],
          ),
        ));
  }
}
