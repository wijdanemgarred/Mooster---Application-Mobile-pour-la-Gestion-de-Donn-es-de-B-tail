import 'package:cloud_firestore/cloud_firestore.dart';

class Weight {
  final String cattleId;
  final String value;
  final DateTime timestamp;

  Weight({
    required this.cattleId,
    required this.value,
    required this.timestamp,
  });

  // helper to make instance of Weight from DocumentSnapshot
  static Weight fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Weight(
      cattleId: doc.reference.parent.parent!.id,
      value: data['weight'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // function to fetch all weights for a specific cattle
  static Future<List<Weight>> fetchAllWeightsByCattleId(String cattleId) async {
    try {
      QuerySnapshot weightSnapshot = await FirebaseFirestore.instance
          .collection('cattle')
          .doc(cattleId)
          .collection('weights')
          .orderBy('timestamp', descending: true)
          .get();

      List<Weight> weights =
          weightSnapshot.docs.map((doc) => Weight.fromFirestore(doc)).toList();

      return weights;
    } catch (e) {
      throw Exception('Failed to fetch weights: $e');
    }
  }

  // function to fetch the letest weight reading for a cattle
  static Future<Weight> fetchNewestWeightByCattleId(String cattleId) async {
    try {
      List<Weight> weights = await fetchAllWeightsByCattleId(cattleId);
      if (weights.isNotEmpty) {
        return weights
            .first; // Weights are sorted by timestamp => the first one is newest
      } else {
        throw Exception(
            "No weight readings found for cattle with ID: $cattleId");
      }
    } catch (e) {
      throw Exception('Failed to fetch the newest weight: $e');
    }
  }
}
