import 'package:flutter/material.dart';
import 'package:zynotes/constants/routes.dart';
import 'package:zynotes/utilities/show_error_dialog.dart';
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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 14, 166, 241),
          centerTitle: true,
          title: const Text('Login'),
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
                        builder: (context) => const Center(
                              child: CircularProgressIndicator(),
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
                  child: const Text('Login'),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          registerView, (route) => route.isFirst);
                    },
                    child: const Text('Create an Account'))
              ],
            )));
  }
}
