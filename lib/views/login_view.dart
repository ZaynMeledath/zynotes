// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:zynotes/constants/routes.dart';
import 'package:zynotes/utilities/dialogs/error_dialog.dart';
import 'package:zynotes/utilities/progress_indicator.dart';
import 'package:zynotes/services/auth/auth_service.dart';
import 'package:zynotes/services/auth/auth_exceptions.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _passwordVisible = true;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
        body: SafeArea(
      child: Column(children: [
        Container(
          width: screenWidth,
          height: isKeyboard ? screenHeight * .10 : screenHeight * .25,
          decoration: const BoxDecoration(
              color: Color.fromARGB(255, 233, 232, 232),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(120),
                  bottomRight: Radius.circular(120))),
          child: const Center(
            child: Text(
              'Login',
              style: TextStyle(
                color: Colors.black,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              TextField(
                controller: _email,
                decoration: InputDecoration(
                    hintText: 'Enter Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18)),
                    prefixIcon: const Icon(Icons.email)),
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextField(
                  controller: _password,
                  autocorrect: false,
                  obscureText: _passwordVisible,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                      hintText: 'Enter Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18)),
                      prefixIcon: const Icon(Icons.password),
                      suffixIcon: IconButton(
                        icon: Icon(_passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      )),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final email = _email.text;
                  final password = _password.text;
                  showDialog(
                      context: context,
                      builder: (context) => Center(
                            child: ActivityIndicator.indicator,
                          ));
                  try {
                    await AuthService.firebase().signIn(
                      email: email,
                      password: password,
                    );
                    final user = AuthService.firebase().currentUser;
                    if (user?.isEmailVerified ?? false) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        homePage,
                        (route) => false,
                      );
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        verifyEmail,
                        (route) => false,
                      );
                    }
                  } on UserNotFoundAuthException {
                    await showErrorDialog(
                      context,
                      'Not a Registered User',
                    );
                  } on WrongPasswordAuthException {
                    await showErrorDialog(
                      context,
                      'Incorrect Password',
                    );
                  } on NetworkRequestFailedAuthException {
                    await showErrorDialog(
                      context,
                      'No internet connection',
                    );
                  } on InvalidEmailAuthException {
                    await showErrorDialog(
                      context,
                      'Please enter a valid email',
                    );
                  } on GenericAuthException {
                    await showErrorDialog(
                      context,
                      'Authentication Error',
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 25,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 221, 220, 220),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Text('Login',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                          )),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        registerView, (route) => route.isFirst);
                  },
                  child: const Text('Create an Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                      )))
            ],
          ),
        ),
      ]),
    ));
  }
}
