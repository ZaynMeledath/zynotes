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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Column(
          children: [
            Stack(children: [
              Container(
                width: screenWidth,
                height: screenHeight * .25,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.lightBlueAccent,
                      Colors.white,
                    ]),
                    // color: Color.fromARGB(141, 73, 73, 73),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(120),
                        bottomRight: Radius.circular(120))),
                child: Image.asset(
                  'assets/images/ColorfulNote.png',
                  width: 250,
                  height: 250,
                ),
              ),
              const Positioned(
                left: 145,
                top: 55,
                child: Text(
                  'Hi',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Positioned(
                left: 210,
                top: 55,
                child: Text(
                  'Guest',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 145),
            const Text(
              'WELCOME TO ZYNOTES',
              style: TextStyle(fontSize: 29, fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginView, (route) => false);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 40,
                ),
                child: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 221, 220, 220),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text('Login or Register',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        )),
                  ),
                ),
              ),
            ),
            const Expanded(
              child: SizedBox(),
            ),
            Container(
              width: screenWidth,
              height: screenHeight * .11,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.lightBlueAccent,
                    Colors.white,
                  ]),
                  // color: Color.fromARGB(141, 73, 73, 73),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(200),
                      topRight: Radius.circular(200))),
            ),
          ],
        ),
      ),
    ));
  }
}
