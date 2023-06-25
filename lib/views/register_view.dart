import 'package:flutter/material.dart';
import 'package:zynotes/constants/routes.dart';
import 'package:zynotes/services/auth/auth_exceptions.dart';
import 'package:zynotes/services/auth/auth_service.dart';
import 'package:zynotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

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
          title: const Text('Register'),
        ),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(hintText: 'Enter Email'),
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _password,
                  decoration: const InputDecoration(hintText: 'Enter Password'),
                  autocorrect: false,
                  obscureText: true,
                  enableSuggestions: false,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    showDialog(
                        context: context,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()));
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
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginView, (route) => false);
                    },
                    child: const Text('Already have an account? Sign in'))
              ],
            )));
  }
}
