import 'package:flutter/material.dart';
import '../model/user.dart';

class UserTile extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;

  const UserTile({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    late ImageProvider categoryImage;

    // assign icon to each category
    switch (user.category.toLowerCase()) {
      case 'admin':
        categoryImage = const AssetImage('assets/images/admin_man_icon.png');
        break;
      case 'owner':
        categoryImage = const AssetImage('assets/images/owner_icon.png');
        break;
      case 'doctor':
        categoryImage = const AssetImage('assets/images/veterinarian_icon.png');
        break;
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: categoryImage,
          radius: 28,
        ),
        title: Text(
          '${_capitalize(user.name)} ${_capitalize(user.surname)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          _capitalize(user.category),
          style: const TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  // utility function  capitalize the first letter of string
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
