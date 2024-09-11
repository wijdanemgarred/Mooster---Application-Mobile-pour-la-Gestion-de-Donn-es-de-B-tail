import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Mooster/login/ConfirmEmail.dart';
import 'package:Mooster/login/forgotPassword.dart';
import 'firebase_options.dart';
import 'login/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Customize theme colors
      ),
      initialRoute: '/', // Set the initial route (usually login)
      routes: {
        '/': (context) => const LogInScreen(), // Login screen route
        '/forgot-password': (context) =>
            const forgotPassword(), // Forgot password route
        '/confirm-email': (context) =>
            const confirmEmail(), // Confirm email route

        // ... add routes for other screens
      },
    );
  }
}
