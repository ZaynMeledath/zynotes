import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
          backgroundColor: Colors.lightBlue,
          centerTitle: true,
          title: const Text('Login'),
        ),
        body: FutureBuilder(
          future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _email,
                          decoration:
                              const InputDecoration(hintText: 'Enter Email'),
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        TextField(
                          controller: _password,
                          decoration:
                              const InputDecoration(hintText: 'Enter Password'),
                          autocorrect: false,
                          obscureText: true,
                          enableSuggestions: false,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final email = _email.text;
                            final password = _password.text;

                            try {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: email, password: password);
                              _email.text = '';
                              _password.text = '';
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'user-not-found') {
                                print('User Not Found');
                              } else if (e.code == 'wrong-password') {
                                print('Wrong Password');
                              } else {
                                print('SOMETHING WENT WRONG');
                                print(e.code);
                              }
                            }
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ));

              default:
                return const Text('Loading...');
            }
          },
        ));
  }
}
