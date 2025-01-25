import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import the login screen

class account_created_screen extends StatelessWidget {
  const account_created_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8), 
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 40.0, vertical: 20.0), 

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top sparkle image
            Center(
              child: Image.asset(
                'lib/assets/accountcreatedLogo.png', 
                height: 150, 
              ),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Account Created',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Your account has been created\nsuccessfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const login_screen()),
                  (Route<dynamic> route) =>
                      false, 
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, 
                padding:
                    const EdgeInsets.symmetric(vertical: 16), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), 
                ),
              ),
              child: const Text(
                'Sign in',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
