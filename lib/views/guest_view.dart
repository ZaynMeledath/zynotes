import 'package:flutter/material.dart';
import 'package:zynotes/constants/routes.dart';

//GUEST HOME VIEW

class GuestView extends StatefulWidget {
  const GuestView({super.key});

  @override
  State<GuestView> createState() => _GuestViewState();
}

class _GuestViewState extends State<GuestView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 14, 166, 241),
          title: const Text('Home Page'),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: Center(
            child: Column(
              children: [
                const Text('Hi Guest'),
                const Text('WELCOME TO ZYNOTES'),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginView, (route) => false);
                    },
                    child: const Text('Login or Register'))
              ],
            ),
          ),
        ));
  }
}
