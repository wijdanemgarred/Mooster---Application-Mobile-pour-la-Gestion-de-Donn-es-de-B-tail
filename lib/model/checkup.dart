import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Mooster/model/cattle.dart';
import 'package:Mooster/model/user.dart';

class Checkup {
  final List<String> meds;
  final String observation;
  final DateTime timestamp;
  final String vaccin;
  final Cattle? cattle;
  final User? doctor;

  Checkup({
    required this.meds,
    required this.observation,
    required this.timestamp,
    required this.vaccin,
    this.cattle,
    this.doctor,
  });

  // Factory method to create an instance of Checkup from Firestore document
  static Future<Checkup> fromFirestore(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Fetch user reference
    User? doctor;
    if (data['user'] != null) {
      DocumentReference userRef = data['user'] as DocumentReference;
      doctor = await User.fetchUserById(userRef.id);
    }

    // Fetch cattle reference
    Cattle? cattle;
    if (data['cattle'] != null) {
      DocumentReference cattleRef = data['cattle'] as DocumentReference;
      cattle = Cattle.fromFirestore(await cattleRef.get());
    }

    return Checkup(
      doctor: doctor,
      cattle: cattle,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      meds: List<String>.from(data['meds']),
      observation: data['observation'] as String,
      vaccin: data['vaccin'] as String,
    );
  }
}
