// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:zynotes/constants/routes.dart';
import 'package:zynotes/services/auth/auth_exceptions.dart';
import 'package:zynotes/services/auth/auth_service.dart';
import 'package:zynotes/utilities/dialogs/error_dialog.dart';
import 'package:zynotes/utilities/progress_indicator.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Register'),
        ),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(
                      hintText: 'Enter Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email)),
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
                        border: const OutlineInputBorder(),
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
                ElevatedButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    showDialog(
                        context: context,
                        builder: (context) =>
                            Center(child: ActivityIndicator.indicator));
                    try {
                      await AuthService.firebase().createUser(
                        email: email,
                        password: password,
                      );
                      await AuthService.firebase().signIn(
                        email: email,
                        password: password,
                      );
                      await AuthService.firebase().sendEmailVerification();
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginView, (route) => false);
                    } on WeakPasswordAuthException {
                      await showErrorDialog(
                        context,
                        'Weak Password',
                      );
                    } on EmailAlreadyInUseAuthException {
                      await showErrorDialog(
                        context,
                        'Email is already in use',
                      );
                    } on InvalidEmailAuthException {
                      await showErrorDialog(
                        context,
                        'Please enter a valid email',
                      );
                    } on NetworkRequestFailedAuthException {
                      await showErrorDialog(
                        context,
                        'No internet connection',
                      );
                    } on GenericAuthException {
                      await showErrorDialog(
                        context,
                        'Authentication Error',
                      );
                    }
                  },
                  child: const Text('Register'),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          loginView, (route) => route.isFirst);
                    },
                    child: const Text('Already have an account? Sign in'))
              ],
            )));
  }
}
