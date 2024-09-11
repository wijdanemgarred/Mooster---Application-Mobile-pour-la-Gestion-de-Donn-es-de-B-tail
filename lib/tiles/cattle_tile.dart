import 'package:flutter/material.dart';
import 'package:Mooster/views/cattle_detail_view.dart';
import 'package:Mooster/views/cattle_detail_view_doctor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/cattle.dart';
import '../model/temperature.dart';
import '../model/weight.dart';
import '../model/user.dart'; // Make sure to import the User model
import 'dart:async';

class CattleTile extends StatefulWidget {
  final Cattle cattle;
  final String userCategory; // Add this parameter
  final VoidCallback? onTap;

  const CattleTile({
    super.key,
    required this.cattle,
    required this.userCategory, // Add this parameter
    this.onTap,
  });

  @override
  State<CattleTile> createState() => _CattleTileState();
}

class _CattleTileState extends State<CattleTile> {
  String latestTemperature = 'Loading...';
  String latestWeight = 'Loading...';
  late StreamSubscription<Temperature> _temperatureSubscription;
  late Color _cardColor = Colors.grey;
  Timer? _colorChangeTimer;
  bool _lockColor = false;

  @override
  void initState() {
    super.initState();
    _initializeCardColor();
    _subscribeToTemperatureUpdates();
    _fetchLatestWeight();
  }

  @override
  void dispose() {
    _temperatureSubscription.cancel();
    _colorChangeTimer?.cancel();
    super.dispose();
  }

  void _initializeCardColor() {
    setState(() {
      _cardColor = _getColorFromState(widget.cattle.state);
    });
  }

  double? parseDouble(String value, {double? defaultValue}) {
    try {
      return double.parse(value);
    } catch (e) {
      return defaultValue;
    }
  }

  void _subscribeToTemperatureUpdates() {
    final temperatureStream =
        Temperature.streamNewestTemperatureByCattleId(widget.cattle.cattleId);
    _temperatureSubscription = temperatureStream.listen((Temperature temp) {
      double? tempValue = parseDouble(temp.value);
      setState(() {
        latestTemperature = '${temp.value} °C';
        if (!_lockColor && tempValue != null) {
          _updateCardColorAndState(tempValue);
        }
      });
    });
  }

  // Sending a notification as well
  void _updateCardColorAndState(double temperature) async {
    String previousState = widget.cattle.state;
    if (widget.cattle.state == 'On Treatment') {
      setState(() {
        _cardColor = Colors.yellow;
      });
    } else if (temperature < 36.0 || temperature > 39.0) {
      setState(() {
        _cardColor = Colors.red;
        widget.cattle.state = 'Sick';
      });
      try {
        await widget.cattle.updateState('Sick');
      } catch (e) {
        print('Failed to update cattle state: $e');
      }
      _sendNotificationIfStateChanged(previousState, 'Sick');
      _colorChangeTimer?.cancel();
      _colorChangeTimer = Timer(const Duration(hours: 1), () {
        setState(() {
          _lockColor = true;
        });
      });
    } else if (temperature >= 36.0 && temperature <= 39.0 ||
        widget.cattle.state == 'Good') {
      setState(() {
        _cardColor = Colors.green;
      });
      try {
        await widget.cattle.updateState('Good');
      } catch (e) {
        print('Failed to update cattle state: $e');
      }
      _sendNotificationIfStateChanged(previousState, 'Good');
      _colorChangeTimer?.cancel();
      _colorChangeTimer = Timer(const Duration(hours: 1), () {
        setState(() {
          _lockColor = true;
        });
      });
    } else if (!_lockColor) {
      Color newColor = _getColorFromState(widget.cattle.state);
      if (_cardColor != newColor) {
        setState(() {
          _cardColor = newColor;
        });
      }
    }
  }

  void _sendNotificationIfStateChanged(
      String previousState, String newState) async {
    if (previousState != newState) {
      try {
        List<User> users = await User.fetchAllUsers();
        for (User user in users) {
          await addNewNotification(
              widget.cattle, user, DateTime.now(), newState);
        }
      } catch (e) {
        print('Failed to fetch users or send notifications: $e');
      }
    }
  }

  Color _getColorFromState(String state) {
    switch (state) {
      case 'Sick':
        return Colors.red;
      case 'Good':
        return Colors.green;
      case 'On Treatment':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  void _fetchLatestWeight() async {
    try {
      Weight weight =
          await Weight.fetchNewestWeightByCattleId(widget.cattle.cattleId);
      setState(() {
        latestWeight = '${weight.value} kg';
      });
    } catch (e) {
      setState(() {
        latestWeight = 'N/A';
      });
    }
  }

  void _toggleLightIndicator(bool value) async {
    String newValue = value ? 'on' : 'off';
    try {
      await widget.cattle.updateLightIndicator(newValue);
      setState(() {
        widget.cattle.lightIndicator = newValue;
      });
    } catch (e) {
      print('Failed to update light indicator: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      color: _cardColor,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/cow_icon.png'),
          backgroundColor: Colors.transparent,
          radius: 28,
        ),
        title: Text(
          widget.cattle.rfid,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(_capitalize(widget.cattle.category)),
        trailing: Switch(
          value: widget.cattle.lightIndicator == 'on',
          onChanged: (bool value) {
            _toggleLightIndicator(value);
          },
        ),
        onTap: () async {
          if (widget.userCategory == 'doctor') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CattleDetailDoctorView(cattleId: widget.cattle.cattleId),
              ),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CattleDetailView(cattleId: widget.cattle.cattleId),
              ),
            );
          }
        },
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
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
