import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Mooster/home/home_page_admin.dart';
import 'package:Mooster/home/home_page_doctor.dart';
import 'package:Mooster/home/home_page_owner.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({
    super.key,
  });

  @override
  State<LogInScreen> createState() {
    return _LogInScreenState();
  }
}

class _LogInScreenState extends State<LogInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        final docSnapshot = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!docSnapshot.exists || docSnapshot.data() == null) {
          showLoginError('User not found in database');
          return;
        }

        final category = docSnapshot.data()!['category'];
        navigateToCategoryPage(category, userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      showLoginError(e.message ?? 'Failed to log in');
    }
  }

  Future<void> navigateBasedOnUserRole(String userId) async {
    final docSnapshot = await _firestore.collection('users').doc(userId).get();

    if (!docSnapshot.exists || docSnapshot.data() == null) {
      showLoginError('User not found in database');
      return;
    }

    final category = docSnapshot.data()!['category'];
    navigateToCategoryPage(category, userId);
  }

  void navigateToCategoryPage(String category, String userId) {
    switch (category) {
      case 'admin':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePageAdmin(
              initialPage: 0,
              userId: userId,
            ),
          ),
        );
        break;
      case 'owner':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePageOwner(
              initialPage: 0,
              userId: userId,
            ),
          ),
        );
        break;
      case 'doctor':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePageDoctor(
              initialPage: 0,
              userId: userId,
            ),
          ),
        );
        break;
      default:
        showLoginError('Unknown user category');
    }
  }

  void showLoginError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/uir-image.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Center(
              child: SingleChildScrollView(child: buildLoginUI()),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoginUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Retirez l'image du logo
        const SizedBox(height: 30),
        buildTitleText(),
        const SizedBox(height: 30),
        buildEmailField(),
        const SizedBox(height: 20),
        buildPasswordField(),
        const SizedBox(height: 20),
        buildForgotPassword(),
        const SizedBox(height: 20),
        // Modifiez le style du bouton de connexion
        buildLoginButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildTitleText() {
    return Text(
      'Mooster',
      style: GoogleFonts.lato(
          color: const Color.fromARGB(255, 227, 242, 245),
          fontSize: 24,
          fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget buildEmailField() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        controller: emailController,
        decoration: const InputDecoration(
          labelText: 'Email',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.email),
        ),
      ),
    );
  }

  Widget buildPasswordField() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      height: 50,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.lock),
        ),
      ),
    );
  }

  Widget buildForgotPassword() {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/forgot-password');
      },
      child: const Text(
        'Forgot Password?',
        style: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          decoration: TextDecoration.underline,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget buildLoginButton() {
    return TextButton(
      onPressed: login,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          const Color.fromARGB(255, 34, 127, 180),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.login,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          SizedBox(width: 8),
          Text(
            'Login',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
