import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Mooster/views/checkup_list_view.dart';
import '../model/cattle.dart';

class CattleDetailView extends StatefulWidget {
  final String cattleId;

  const CattleDetailView({super.key, required this.cattleId});

  @override
  State<CattleDetailView> createState() => _CattleDetailViewState();
}

class _CattleDetailViewState extends State<CattleDetailView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _rfidController = TextEditingController();
  final TextEditingController _esp32Controller = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _lightIndicatorController =
      TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _dayOfBirthController = TextEditingController();
  final TextEditingController _dayOfArrivalController = TextEditingController();
  final TextEditingController _emplacementController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _raceController = TextEditingController();
  final TextEditingController _typeracialController = TextEditingController();
  final TextEditingController _vaccineController = TextEditingController();
  final TextEditingController _pregnancyDateController =
      TextEditingController();

  bool _isLoading = true;
  late Cattle _cattle;

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Informations sur le Bétail')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Informations sur le Bétail')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/cow_icon.png'),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 20),
              Text(
                _rfidController.text,
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
                      _cattle.vaccine.map((vaccine) => Text(vaccine)).toList(),
                ),
              ),
              ListTile(
                title: const Text('Enceinte'),
                subtitle: Text(_cattle.pregnancy ? 'Oui' : 'Non'),
              ),
              if (_cattle.pregnancy)
                ListTile(
                  title: const Text('Date de la Gestation'),
                  subtitle: Text(_pregnancyDateController.text.split(' ')[0]),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CheckupListView(cattleId: widget.cattleId),
                        ),
                      );
                    },
                    child: const Text(
                      'Dernier Contrôle',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      backgroundColor: Colors.yellow,
                    ),
                    onPressed: _toggleLightIndicator,
                    child: Text(
                      _lightIndicatorController.text.toLowerCase() == 'on'
                          ? 'Éteindre Indicateur'
                          : 'Allumer Indicateur',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleLightIndicator() async {
    // Toggle light indicator state
    String newIndicator =
        _lightIndicatorController.text.toLowerCase() == 'on' ? 'off' : 'on';

    try {
      await FirebaseFirestore.instance
          .collection('cattle')
          .doc(widget.cattleId)
          .update({
        'lightIndicator': newIndicator,
      });

      setState(() {
        _lightIndicatorController.text = newIndicator;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Indicateur Lumineux $newIndicator')),
      );
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'indicateur lumineux: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Échec de la mise à jour de l\'indicateur lumineux: $e')),
      );
    }
  }
}
