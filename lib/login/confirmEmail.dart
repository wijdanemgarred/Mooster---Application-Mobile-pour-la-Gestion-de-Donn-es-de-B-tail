import 'package:flutter/material.dart';

class confirmEmail extends StatelessWidget {
  const confirmEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Email'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'A password reset link has been sent to your email.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/'); // Use named route
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
