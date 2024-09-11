import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import notification model

class NotificationList extends StatefulWidget {
  final String userId; // UserId of the current logged-in user

  const NotificationList({super.key, required this.userId});

  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  List<String> notifications = [];
  bool isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    List<String> fetchedNotifications =
        await getFormattedNotificationsForUser(widget.userId);
    _updateNotifications(fetchedNotifications);
  }

  void _updateNotifications(List<String> newNotifications) {
    setState(() {
      notifications = newNotifications;
      isLoading = false; // Update loading state
    });
  }

  Future<void> _deleteAllNotifications() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('user',
              isEqualTo: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId))
          .get();

      for (DocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      _updateNotifications([]); // Clear local notifications list
    } catch (e) {
      print('Failed to delete notifications: $e');
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 60,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: const Icon(Icons.notifications),
            title: Text(notifications[index]),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : notifications.isEmpty
              ? _buildEmptyState()
              : Stack(
                  children: [
                    _buildNotificationList(),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FloatingActionButton(
                          onPressed: _deleteAllNotifications,
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.clear),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  static Future<List<String>> getFormattedNotificationsForUser(
      String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<String> formattedNotifications = [];

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('notifications')
          .where('user', isEqualTo: firestore.collection('users').doc(userId))
          .orderBy('timestamp', descending: true)
          .get();

      List<QueryDocumentSnapshot> documents = querySnapshot.docs;

      for (var doc in documents) {
        DocumentSnapshot notificationDoc = await doc.reference.get();
        Map<String, dynamic> data =
            notificationDoc.data() as Map<String, dynamic>;

        // Fetch cattle data as a Map
        DocumentReference cattleRef = data['cattle'] as DocumentReference;
        DocumentSnapshot cattleDoc = await cattleRef.get();
        Map<String, dynamic> cattleData =
            cattleDoc.data() as Map<String, dynamic>;

        String cattleRfid = '${cattleData['rfid']}';
        String notificationType = data['type'];
        DateTime notificationTimestamp =
            (data['timestamp'] as Timestamp).toDate();

        String timeAgoMessage = _formatTimeAgo(notificationTimestamp);

        String notificationMessage = '';

        switch (notificationType) {
          case 'Good':
            notificationMessage =
                '$timeAgoMessage\nYour cattle with RFID: $cattleRfid is in good health.';
            break;
          case 'Sick':
            notificationMessage =
                '$timeAgoMessage\nYour cattle with RFID: $cattleRfid is in bad health.';
            break;
          case 'On Treatment':
            notificationMessage =
                '$timeAgoMessage\nThe doctor has viewed the cattle with RFID: $cattleRfid, and it is on treatment.';
            break;
          default:
            notificationMessage =
                '$timeAgoMessage\nNew notification type: $notificationType';
        }

        formattedNotifications.add(notificationMessage);
      }

      return formattedNotifications;
    } catch (e) {
      print("Error fetching notifications: $e");
      return [];
    }
  }

  static String _formatTimeAgo(DateTime notificationTimestamp) {
    Duration duration = DateTime.now().difference(notificationTimestamp);

    if (duration.inDays > 0) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }
}
