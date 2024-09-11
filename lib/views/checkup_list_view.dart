import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Mooster/model/cattle.dart';
import 'package:Mooster/model/user.dart';
import 'package:Mooster/model/checkup.dart';

class CheckupListView extends StatefulWidget {
  final String cattleId;

  const CheckupListView({super.key, required this.cattleId});

  @override
  _CheckupListViewState createState() => _CheckupListViewState();
}

class _CheckupListViewState extends State<CheckupListView> {
  late Future<List<Checkup>> _checkupsFuture;

  @override
  void initState() {
    super.initState();
    _checkupsFuture = fetchCheckups();
  }

  Future<List<Checkup>> fetchCheckups() async {
    try {
      print('Fetching checkups for cattle ID: ${widget.cattleId}');
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('checkups')
          .where('cattle',
              isEqualTo: FirebaseFirestore.instance
                  .collection('cattle')
                  .doc(widget.cattleId))
          .orderBy('timestamp', descending: true)
          .get();

      List<Checkup> checkups = [];

      for (var doc in snapshot.docs) {
        DocumentSnapshot checkupDoc = await doc.reference.get();
        Map<String, dynamic> data = checkupDoc.data() as Map<String, dynamic>;
        print('Checkup data: $data');

        // Fetch user data for the doctor
        User? doctor;
        if (data['doctor'] != null) {
          print('Fetching doctor for user ref: ${data['doctor']}');
          doctor = await fetchDoctor(data['doctor'] as DocumentReference);
          print(
              'Fetched doctor: ${doctor != null ? "${doctor.name} ${doctor.surname}" : "Unknown"}');
        }

        // Fetch cattle data
        Cattle? cattle;
        if (data['cattle'] != null) {
          DocumentReference cattleRef = data['cattle'] as DocumentReference;
          DocumentSnapshot cattleDoc = await cattleRef.get();
          cattle = Cattle.fromFirestore(cattleDoc);
          print('Fetched cattle: $cattle');
        }

        // Create Checkup object
        Checkup checkup = Checkup(
          doctor: doctor,
          cattle: cattle,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          meds: List<String>.from(data['meds']),
          observation: data['observation'] as String,
          vaccin: data['vaccin'] as String,
        );

        checkups.add(checkup);
      }

      return checkups;
    } catch (e) {
      print('Error fetching checkups: $e');
      throw Exception('Failed to fetch checkups: $e');
    }
  }

  Future<User?> fetchDoctor(DocumentReference userRef) async {
    try {
      DocumentSnapshot userDoc = await userRef.get();
      if (userDoc.exists) {
        print('Doctor document exists: ${userDoc.data()}');
        return User.fromFirestore(userDoc);
      } else {
        print('Doctor document does not exist for ref: $userRef');
      }
      return null;
    } catch (e) {
      print('Error fetching doctor: $e');
      return null;
    }
  }

  String calculateTimeDifference(DateTime timestamp) {
    Duration difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkup List'),
      ),
      body: FutureBuilder<List<Checkup>>(
        future: _checkupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No checkups found'));
          }

          List<Checkup> checkups = snapshot.data!;
          return ListView.builder(
            itemCount: checkups.length,
            itemBuilder: (context, index) {
              Checkup checkup = checkups[index];
              String timeAgo = calculateTimeDifference(checkup.timestamp);
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading:
                      const Icon(Icons.medical_services, color: Colors.blue),
                  title: Text(
                    checkup.observation,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (checkup.doctor != null)
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.blue),
                            const SizedBox(width: 8.0),
                            Text(
                                'Doctor: ${checkup.doctor!.name} ${checkup.doctor!.surname}'),
                          ],
                        ),
                      if (checkup.doctor == null)
                        const Row(
                          children: [
                            Icon(Icons.person_outline, color: Colors.grey),
                            SizedBox(width: 8.0),
                            Text('Doctor: Unknown'),
                          ],
                        ),
                      Row(
                        children: [
                          const Icon(Icons.vaccines, color: Colors.blue),
                          const SizedBox(width: 8.0),
                          Text('Vaccine: ${checkup.vaccin}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.medication, color: Colors.blue),
                          const SizedBox(width: 8.0),
                          Text('Medications: ${checkup.meds.join(', ')}'),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(Icons.schedule, color: Colors.grey),
                          const SizedBox(width: 8.0),
                          Text(
                            timeAgo,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
