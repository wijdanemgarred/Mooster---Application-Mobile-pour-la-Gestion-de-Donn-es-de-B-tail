// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class User {
  final String userId;
  final String category;
  final String name;
  final String surname;
  final String email;
  final String phone;

  User({
    required this.userId,
    required this.category,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
  });

  // function to create User from a DocumentSnapshot
  static User fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return User(
      userId: doc.id,
      category: data['category'] as String,
      name: data['name'] as String,
      surname: data['surname'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String,
    );
  }

  // function to fetch a User by document ID
  static Future<User> fetchUserById(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return User.fromFirestore(userDoc);
      } else {
        throw Exception("No user found with ID: $userId");
      }
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  // function to fetch all users
  static Future<List<User>> fetchAllUsers() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      List<User> users =
          querySnapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
      return users;
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  // function to fetch users by category
  static Future<List<User>> fetchUsersByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('category', isEqualTo: category)
          .get();
      List<User> users =
          querySnapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
      return users;
    } catch (e) {
      throw Exception('Failed to fetch users by category: $e');
    }
  }

  // update the user email in Firebase Authentication
  static Future<void> updateUserEmail(String newEmail) async {
    try {
      firebase_auth.User? currentUser =
          firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.verifyBeforeUpdateEmail(newEmail);
        print(
            "Verification email sent to current email for updating to new email.");
      } else {
        throw Exception("No user logged in.");
      }
    } catch (e) {
      throw Exception('Failed to initiate email update: $e');
    }
  }

  // function to add new user
  static Future<void> addUser(String email, String password, String name,
      String surname, String category, String phone) async {
    try {
      // use FirebaseAuth service to create user
      firebase_auth.UserCredential result = await firebase_auth
          .FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      firebase_auth.User? newUser = result.user;

      if (newUser != null) {
        // Use generated UID from FirebaseAuth as the Firestore document ID
        await FirebaseFirestore.instance
            .collection('users')
            .doc(newUser.uid)
            .set({
          'name': name,
          'surname': surname,
          'category': category,
          'email': email,
          'phone': phone,
        });
      }
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  // change user password in Authentication service
  static Future<void> updateUserPassword(String newPassword) async {
    try {
      firebase_auth.User? currentUser =
          firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.updatePassword(newPassword);
        print("Password updated successfully.");
      } else {
        throw Exception("No user logged in.");
      }
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // method to login by email and password and get this user category
  static Future<Map<String, dynamic>> loginUserAndGetCategory(
      String email, String password) async {
    try {
      firebase_auth.UserCredential userCredential =
          await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email.trim(), password: password.trim());

      String userId = userCredential.user!.uid;
      String category = await getUserCategory(userId);

      print("User logged in and category fetched successfully.");
      return {'userCredential': userCredential, 'category': category};
    } catch (e) {
      throw Exception('Failed to log in and fetch category: $e');
    }
  }

  // method to get user category by user ID
  static Future<String> getUserCategory(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw Exception("User not found in Firestore.");
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String category = userData['category'];
      if (category.isEmpty) {
        throw Exception("User category is undefined.");
      }

      return category;
    } catch (e) {
      throw Exception('Failed to fetch user category: $e');
    }
  }

  // method to log out the current user
  static Future<void> logout() async {
    try {
      await firebase_auth.FirebaseAuth.instance.signOut();
      print("User has been logged out successfully.");
    } catch (e) {
      throw Exception('Failed to log out: $e');
    }
  }
}
