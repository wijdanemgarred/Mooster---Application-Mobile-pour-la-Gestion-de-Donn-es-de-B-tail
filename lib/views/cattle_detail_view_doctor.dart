import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Mooster/add/add_checkup.dart';
import 'package:Mooster/views/checkup_list_view.dart';
import '../model/user.dart';
import '../model/cattle.dart';

class CattleDetailDoctorView extends StatefulWidget {
  final String cattleId;

  const CattleDetailDoctorView({super.key, required this.cattleId});

  @override
  State<CattleDetailDoctorView> createState() => _CattleDetailDoctorViewState();
}

class _CattleDetailDoctorViewState extends State<CattleDetailDoctorView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _rfidController = TextEditingController();
  final TextEditingController _esp32Controller = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _lightIndicatorController =
      TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _dayOfBirthController = TextEditingController();
  final TextEditingController _dayOfArrivalController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _emplacementController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _raceController = TextEditingController();
  final TextEditingController _typeracialController = TextEditingController();
  final TextEditingController _vaccineController = TextEditingController();
  final TextEditingController _pregnancyDateController =
      TextEditingController();

  bool _isLoading = true;
  Cattle? _cattle;

  @override
  void initState() {
    super.initState();
    _fetchCattleDetails();
  }

  Future<void> _fetchCattleDetails() async {
    try {
      setState(() => _isLoading = true);
      // fetch cattle using existing methods
      Cattle cattle = await Cattle.fetchCattleById(widget.cattleId);

      // set the fields with data
      _rfidController.text = cattle.rfid;
      _esp32Controller.text = cattle.esp32;
      _categoryController.text = cattle.category;
      _lightIndicatorController.text = cattle.lightIndicator;
      _dayOfBirthController.text = cattle.dayOfBirth.toString();
      _dayOfArrivalController.text = cattle.dayOfArrival.toString();
      _emplacementController.text = cattle.emplacement;
      _genderController.text = cattle.gender;
      _originController.text = cattle.origin;
      _raceController.text = cattle.race;
      _typeracialController.text = cattle.typeracial;
      _vaccineController.text = cattle.vaccine.join(', ');
      _pregnancyDateController.text = cattle.dayOfPregnancy?.toString() ?? '';

      // owner is a DocumentReference
      DocumentSnapshot ownerSnapshot = await cattle.owner.get();
      Map<String, dynamic> ownerData =
          ownerSnapshot.data() as Map<String, dynamic>;
      _ownerNameController.text =
          '${ownerData['name']} ${ownerData['surname']}';

      // Assign the fetched cattle to the _cattle instance variable
      setState(() {
        _cattle = cattle;
      });
    } catch (e) {
      print('Error fetching cattle details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchLatestTemperature() async {
    try {
      QuerySnapshot temperatureSnapshot = await FirebaseFirestore.instance
          .collection('cattle')
          .doc(widget.cattleId)
          .collection('temperatures')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (temperatureSnapshot.docs.isNotEmpty) {
        DocumentSnapshot latestTempDoc = temperatureSnapshot.docs.first;
        Map<String, dynamic> tempData =
            latestTempDoc.data() as Map<String, dynamic>;
        _temperatureController.text = '${tempData['temperature']} °C';
      } else {
        _temperatureController.text = 'No data';
      }
    } catch (e) {
      print('Error fetching latest temperature: $e');
    }
  }

  Future<void> _updateCattleState(String newState) async {
    if (_cattle == null) return;

    try {
      await _cattle!.updateState(newState);
      setState(() {
        _cattle!.state = newState;
      });

      // Fetch owner users
      List<User> ownerUsers = await _fetchOwnerUsers();

      // Send notifications to owner users
      for (User owner in ownerUsers) {
        await _sendNotification(owner, newState);
      }
    } catch (e) {
      print('Error updating cattle state: $e');
    }
  }

  Future<void> _sendNotification(User owner, String newState) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'user':
            FirebaseFirestore.instance.collection('users').doc(owner.userId),
        'cattle': FirebaseFirestore.instance
            .collection('cattle')
            .doc(_cattle!.cattleId),
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'type': newState,
      });
    } catch (e) {
      print('Failed to send notification: $e');
    }
  }

  Color getButtonColor(String state) {
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

  String getNextState(String currentState) {
    switch (currentState) {
      case 'Sick':
        return 'On Treatment';
      case 'On Treatment':
        return 'Good';
      default:
        throw Exception('Invalid state');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cattle Information')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_cattle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cattle Information')),
        body: const Center(child: Text('Cattle not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cattle Information')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/cow_icon.png'),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 20),
              Text(_rfidController.text,
                  style: Theme.of(context).textTheme.titleLarge),
              ListTile(
                title: const Text('ESP32 MAC'),
                subtitle: Text(_esp32Controller.text),
              ),
              ListTile(
                title: const Text('Catégorie'),
                subtitle: Text(_categoryController.text),
              ),
              ListTile(
                title: const Text('Date de Naissance'),
                subtitle: Text(_dayOfBirthController.text.split(' ')[0]),
              ),
              ListTile(
                title: const Text('Date d\'Arrivée'),
                subtitle: Text(_dayOfArrivalController.text.split(' ')[0]),
              ),
              ListTile(
                title: const Text('Emplacement'),
                subtitle: Text(_emplacementController.text),
              ),
              ListTile(
                title: const Text('Genre'),
                subtitle: Text(_genderController.text),
              ),
              ListTile(
                title: const Text('Origine'),
                subtitle: Text(_originController.text),
              ),
              ListTile(
                title: const Text('Race'),
                subtitle: Text(_raceController.text),
              ),
              ListTile(
                title: const Text('Type de Race'),
                subtitle: Text(_typeracialController.text),
              ),
              ListTile(
                title: const Text('Vaccins'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      _cattle!.vaccine.map((vaccine) => Text(vaccine)).toList(),
                ),
              ),
              ListTile(
                title: const Text('Enceinte'),
                subtitle: Text(_cattle!.pregnancy ? 'Oui' : 'Non'),
              ),
              if (_cattle!.pregnancy)
                ListTile(
                  title: const Text('Date de la Gestation'),
                  subtitle: Text(_pregnancyDateController.text.split(' ')[0]),
                ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCheckup(
                    cattleId: widget.cattleId,
                    onCheckupAdded: () {
                      _fetchCattleDetails();
                    },
                  ),
                ),
              );
            },
            label: const Text('Ajouter un contrôle'),
            icon: const Icon(Icons.add),
            backgroundColor: Colors.green,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton.extended(
                onPressed: () async {
                  String newState = getNextState(_cattle!.state);
                  await _updateCattleState(newState);
                },
                label: Text('State: ${_cattle!.state}'),
                icon: const Icon(Icons.update),
                backgroundColor: getButtonColor(_cattle!.state),
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CheckupListView(cattleId: widget.cattleId),
                    ),
                  );
                },
                label: const Text('Dernier Contrôle'),
                icon: const Icon(Icons.list),
                backgroundColor: Colors.blue,
              ),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<List<User>> _fetchOwnerUsers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('category', isEqualTo: 'owner')
          .get();
      List<User> ownerUsers =
          querySnapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
      return ownerUsers;
    } catch (e) {
      print('Failed to fetch owner users: $e');
      return [];
    }
  }
}
