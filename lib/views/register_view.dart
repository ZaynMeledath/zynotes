import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zynotes/constants/routes.dart';
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
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          )
                          .then((value) =>
                              FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: email,
                                password: password,
                              ))
                          .then((value) {
                        final user = FirebaseAuth.instance.currentUser;
                        user?.sendEmailVerification();
                      }).then((value) => Navigator.of(context)
                              .pushNamedAndRemoveUntil(
                                  loginView, (route) => false));
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        await showErrorDialog(
                          context,
                          'Weak Password',
                        );
                      } else if (e.code == 'email-already-in-use') {
                        await showErrorDialog(
                          context,
                          'Email is already in use',
                        );
                      } else if (e.code == 'invalid-email') {
                        await showErrorDialog(
                          context,
                          'Please enter a valid email',
                        );
                      } else {
                        await showErrorDialog(
                          context,
                          'Error: ${e.code}',
                        );
                      }
                    } catch (e) {
                      await showErrorDialog(
                        context,
                        e.toString(),
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
