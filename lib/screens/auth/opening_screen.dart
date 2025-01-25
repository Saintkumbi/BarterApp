import 'package:flutter/material.dart';
import 'welcome_screen.dart'; // Navigate to welcome screen after splash

class opening_screen extends StatefulWidget {
  const opening_screen({super.key});

  @override
  _opening_screenState createState() => _opening_screenState();
}

class _opening_screenState extends State<opening_screen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the Welcome Screen after a delay (3 seconds)
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const welcome_screen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFC043),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                'lib/assets/openingLogo.jpg',
                height: 150,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.asset(
                  'lib/assets/home_logo-removebg.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
