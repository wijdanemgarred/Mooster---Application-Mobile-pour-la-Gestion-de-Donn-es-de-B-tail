import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Mooster/model/cattle.dart';
import 'package:Mooster/model/user.dart';

class Notification {
  final String id;
  final User user;
  final Cattle cattle;
  final DateTime timestamp;
  final String type;

  Notification({
    required this.id,
    required this.user,
    required this.cattle,
    required this.timestamp,
    required this.type,
  });

  static Future<Notification> fromFirestore(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Fetch user reference
    DocumentReference userRef = data['user'] as DocumentReference;
    // Retrieve user data
    User user = User.fromFirestore(await userRef.get());

    // Fetch cattle reference
    DocumentReference cattleRef = data['cattle'] as DocumentReference;
    // Retrieve cattle data
    Cattle cattle = Cattle.fromFirestore(await cattleRef.get());

    return Notification(
      id: doc.id,
      user: user,
      cattle: cattle,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: data['type'] as String,
    );
  }

  static Future<DocumentReference?> addNewNotification(
      Cattle cattle, User user, DateTime timestamp, String type) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentReference notificationRef =
          await firestore.collection('notifications').add({
        'user': firestore.collection('users').doc(user.userId),
        'cattle': firestore.collection('cattle').doc(cattle.cattleId),
        'timestamp': Timestamp.fromDate(timestamp),
        'type': type,
      });

      return notificationRef;
    } catch (e) {
      print("Error adding notification: $e");
      return null;
    }
  }
}
