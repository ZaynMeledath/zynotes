// ignore_for_file: use_build_context_synchronously

import 'package:zynotes/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:zynotes/constants/routes.dart';
import 'package:zynotes/services/auth/auth_exceptions.dart';
import 'package:zynotes/utilities/dialogs/error_dialog.dart';
import 'package:zynotes/utilities/progress_indicator.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final user = AuthService.firebase().currentUser!;
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight * .25,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 233, 232, 232),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(120),
                      bottomRight: Radius.circular(120))),
              child: const Center(
                child: Text(
                  'Verify Email',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Text('Click to verify your email ${user.email}'),
            ElevatedButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) =>
                          Center(child: ActivityIndicator.indicator));
                  if (!user.isEmailVerified) {
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
