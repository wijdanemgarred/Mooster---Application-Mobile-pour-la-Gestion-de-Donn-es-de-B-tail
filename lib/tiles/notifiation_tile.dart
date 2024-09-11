import 'package:flutter/material.dart';
import 'package:Mooster/model/notification.dart' as model;

class NotificationTile extends StatelessWidget {
  final model.Notification notification;

  const NotificationTile({super.key, required this.notification});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.user.name,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Cattle ID: ${notification.cattle.cattleId}',
                    style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Timestamp: ${notification.timestamp}',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Add your actions here
              },
            ),
          ],
        ),
      ),
    );
  }
}
