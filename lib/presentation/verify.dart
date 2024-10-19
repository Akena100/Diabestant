import 'package:flutter/material.dart';

import 'login.dart';

class EmailVerificationInstructions extends StatelessWidget {
  const EmailVerificationInstructions({super.key});
  static const  String id='verify';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Verification email sent!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'We have sent a verification email to your email address. Please check your inbox and follow the instructions to complete the registration process.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, Login.id);
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
