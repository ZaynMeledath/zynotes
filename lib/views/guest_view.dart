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
          title: const Text('Home Page'),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: Center(
            child: Column(
              children: [
                const Padding(
                    padding: EdgeInsets.only(bottom: 8, top: 3),
                    child: Text(
                      'Hi Guest',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                const Text(
                  'WELCOME TO ZYNOTES',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginView, (route) => false);
                      },
                      child: const Text('Login or Register')),
                )
              ],
            ),
          ),
        ));
  }
}
