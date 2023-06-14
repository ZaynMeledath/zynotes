import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:zynotes/firebase_options.dart';

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
          backgroundColor: Colors.lightBlue,
          centerTitle: true,
          title: const Text('Register'),
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
                                  .createUserWithEmailAndPassword(
                                      email: email, password: password);
                              _email.text = '';
                              _password.text = '';
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'weak-password') {
                                print('Weak Password');
                              } else if (e.code == 'email-already-in-use') {
                                print('Email is already in use');
                              } else {
                                print('SOMETHING WENT WRONG');
                                print(e.code);
                              }
                            }
                          },
                          child: const Text('Register'),
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
