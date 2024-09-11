import 'package:cloud_firestore/cloud_firestore.dart';

class Temperature {
  final String cattleId;
  final String value;
  final DateTime timestamp;

  Temperature({
    required this.cattleId,
    required this.value,
    required this.timestamp,
  });

  // function to make instance of Temperature from DocumentSnapshot
  static Temperature fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Temperature(
      cattleId: doc.reference.parent.parent!.id,
      value: data['temperature'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // function to fetch all temperatures for a cattle
  static Future<List<Temperature>> fetchAllTemperaturesByCattleId(
      String cattleId) async {
    try {
      QuerySnapshot temperatureSnapshot = await FirebaseFirestore.instance
          .collection('cattle')
          .doc(cattleId)
          .collection('temperatures')
          .orderBy('timestamp', descending: true)
          .get();

      List<Temperature> temperatures = temperatureSnapshot.docs
          .map((doc) => Temperature.fromFirestore(doc))
          .toList();

      return temperatures;
    } catch (e) {
      throw Exception('Failed to fetch temperatures: $e');
    }
  }

  // function to peak the newest temperature reading for specific cattle
  static Future<Temperature> fetchNewestTemperatureByCattleId(
      String cattleId) async {
    try {
      // using fetchAllTemperaturesByCattleId
      List<Temperature> temperatures =
          await fetchAllTemperaturesByCattleId(cattleId);
      if (temperatures.isNotEmpty) {
        return temperatures
            .first; // temperatures are sorted by timestamp => the first one is newest
      } else {
        throw Exception(
            "No temperature readings found for cattle with ID: $cattleId");
      }
    } catch (e) {
      throw Exception('Failed to fetch the newest temperature: $e');
    }
  }

  // Stream for real-time temperature updates
  static Stream<Temperature> streamNewestTemperatureByCattleId(
      String cattleId) {
    return FirebaseFirestore.instance
        .collection('cattle')
        .doc(cattleId)
        .collection('temperatures')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return fromFirestore(snapshot.docs.first);
      } else {
        throw Exception("No temperature readings available.");
      }
    });
  }
}
