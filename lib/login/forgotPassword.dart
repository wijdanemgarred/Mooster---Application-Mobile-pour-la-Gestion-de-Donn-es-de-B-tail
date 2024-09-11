// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Mooster/login/confirmEmail.dart';

class forgotPassword extends StatefulWidget {
  static String id = 'forgot-password';
  const forgotPassword({super.key});

  @override
  State<forgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<forgotPassword> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>(); // Form key
  String _email = ''; // Email state variable

  Future<void> _passwordReset() async {
    try {
      _formKey.currentState!.save(); // Save form state before sending request
      await _auth.sendPasswordResetEmail(email: _email);
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const confirmEmail()),
      );
    } catch (error) {
      // ignore: avoid_print
      print('Password reset error: $error');
      // Display error message to the user (e.g., using a SnackBar)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'), // Add AppBar for better UI
      ),
      body: Form(
        key: _formKey, // Assign form key
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                onSaved: (newEmail) {
                  // Save email on form submission
                  _email = newEmail ?? ''; // Handle null case
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _passwordReset, // Call passwordReset on button press
                child: const Text('Send Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
