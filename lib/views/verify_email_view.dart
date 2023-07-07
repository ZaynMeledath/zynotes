// ignore_for_file: use_build_context_synchronously

import 'package:zynotes/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:zynotes/constants/routes.dart';
import 'package:zynotes/services/auth/auth_exceptions.dart';
import 'package:zynotes/utilities/show_error_dialog.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.firebase().currentUser;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Verify Email'),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Center(
            child: Column(
              children: [
                Text('Click to verify your email ${user?.email}'),
                ElevatedButton(
                    onPressed: () async {
                      if (user == null) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginView, (route) => false);
                      } else if (!user.isEmailVerified) {
                        try {
                          await AuthService.firebase().sendEmailVerification();
                        } on NetworkRequestFailedAuthException {
                          await showErrorDialog(
                            context,
                            'No internet connection',
                          );
                        }
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
          ),
        ));
  }
}
