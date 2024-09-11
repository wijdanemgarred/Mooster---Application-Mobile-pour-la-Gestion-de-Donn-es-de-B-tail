import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Cattle {
  final String cattleId;
  final String rfid;
  final String esp32;
  final DateTime dayOfBirth;
  final DateTime dayOfArrival;
  final String category;
  final DocumentReference owner;
  String lightIndicator;
  String state;
  final String emplacement;
  final String gender;
  final String origin;
  final String race;
  final String typeracial;
  final List<String> vaccine;
  final bool pregnancy;
  final DateTime dayOfPregnancy;

  Cattle({
    required this.cattleId,
    required this.rfid,
    required this.esp32,
    required this.dayOfBirth,
    required this.dayOfArrival,
    required this.category,
    required this.owner,
    required this.lightIndicator,
    required this.state,
    required this.emplacement,
    required this.gender,
    required this.origin,
    required this.race,
    required this.typeracial,
    required this.vaccine,
    required this.pregnancy,
    required this.dayOfPregnancy,
  });

  factory Cattle.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('DocumentSnapshot data was null');
    }

    return Cattle(
      cattleId: doc.id,
      rfid: data['rfid'] as String? ?? '',
      esp32: data['esp32'] as String? ?? '',
      dayOfBirth:
          (data['dayOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dayOfArrival:
          (data['dayOfArrival'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: data['category'] as String? ?? '',
      owner: data['owner'] as DocumentReference? ??
          FirebaseFirestore.instance.collection('users').doc('defaultOwnerID'),
      lightIndicator: data['lightIndicator'] as String? ?? '',
      state: data['state'] as String? ?? '',
      emplacement: data['emplacement'] as String? ?? '',
      gender: data['gender'] as String? ?? '',
      origin: data['origin'] as String? ?? '',
      race: data['race'] as String? ?? '',
      typeracial: data['type racial'] as String? ?? '',
      vaccine: List<String>.from(data['vaccine'] ?? []),
      pregnancy: data['pregnancy'] as bool? ?? false,
      dayOfPregnancy:
          (data['dayOfPregnancy'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Function to fetch all cattles
  static Future<List<Cattle>> fetchAllCattles() async {
    try {
      QuerySnapshot cattleSnapshot =
          await FirebaseFirestore.instance.collection('cattle').get();
      List<Cattle> fetchedCattles =
          cattleSnapshot.docs.map((doc) => Cattle.fromFirestore(doc)).toList();
      return fetchedCattles;
    } catch (e) {
      throw Exception('Failed to fetch cattles: $e');
    }
  }

  // Function to fetch a single cattle by doc ID
  static Future<Cattle> fetchCattleById(String id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('cattle').doc(id).get();

      if (documentSnapshot.exists) {
        return Cattle.fromFirestore(documentSnapshot);
      } else {
        throw Exception("No cattle found with ID: $id");
      }
    } catch (e) {
      throw Exception('Failed to fetch cattle: $e');
    }
  }

  // Function to fetch an instance of Cattle by rfid
  static Future<Cattle> fetchCattleByRFID(String rfid) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cattle')
          .where('rfid', isEqualTo: rfid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Cattle.fromFirestore(querySnapshot.docs.first);
      } else {
        throw Exception("No cattle found with RFID: $rfid");
      }
    } catch (e) {
      throw Exception('Failed to fetch cattle: $e');
    }
  }

  // Method to update the lightIndicator in Firestore
  Future<void> updateLightIndicator(String value) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('cattle').doc(cattleId).update({
        'lightIndicator': value,
      });
      lightIndicator = value;
    } catch (e) {
      print('Failed to update light indicator: $e');
    }
  }

  // Function to fetch cattles by owner
  static Future<List<Cattle>> fetchCattlesByOwner(String ownerId) async {
    try {
      QuerySnapshot cattleSnapshot = await FirebaseFirestore.instance
          .collection('cattle')
          .where('owner',
              isEqualTo:
                  FirebaseFirestore.instance.collection('users').doc(ownerId))
          .get();

      List<Cattle> cattles =
          cattleSnapshot.docs.map((doc) => Cattle.fromFirestore(doc)).toList();

      return cattles;
    } catch (e) {
      throw Exception('Failed to fetch cattles for owner ID: $ownerId');
    }
  }

  // Function to update the state of the cattle in Firestore
  Future<void> updateState(String newState) async {
    try {
      await FirebaseFirestore.instance
          .collection('cattle')
          .doc(cattleId)
          .update({'state': newState});
      state = newState;
    } catch (e) {
      throw Exception('Failed to update cattle state: $e');
    }
  }
}
