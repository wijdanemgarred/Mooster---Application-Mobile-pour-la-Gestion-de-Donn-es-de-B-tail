import 'package:flutter/material.dart';
import 'package:Mooster/components/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class AddCattle extends StatefulWidget {
  final VoidCallback? onCattleAdded;
  const AddCattle({super.key, this.onCattleAdded});

  @override
  State<AddCattle> createState() => _AddCattleState();
}

class _AddCattleState extends State<AddCattle> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _rfidController = TextEditingController();
  final TextEditingController _esp32Controller = TextEditingController();
  final TextEditingController _dayOfBirthController = TextEditingController();
  final TextEditingController _dayOfArrivalController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _lightIndicatorController =
      TextEditingController();
  final TextEditingController _vaccineController = TextEditingController();
  final TextEditingController _raceController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _emplacementNumberController =
      TextEditingController();

  String _gender = 'Mâle';
  String _typeRacial = 'Viande';
  String _emplacement = 'Étable';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter du Bétail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Informations Générales'),
                _buildNameField('RFID', _rfidController),
                _buildNameField('ESP32 MAC', _esp32Controller),
                _buildDateField('Date de Naissance', _dayOfBirthController),
                _buildDateField('Date d\'Arrivée', _dayOfArrivalController),
                _buildNameField('Catégorie', _categoryController),
                _buildRadioField('Sexe', ['Mâle', 'Femelle'], (value) {
                  setState(() {
                    _gender = value!;
                  });
                }),
                _buildRadioField('Type Racial', ['Viande', 'Lait'], (value) {
                  setState(() {
                    _typeRacial = value!;
                  });
                }),
                _buildNameField('Race', _raceController),
                _buildNameField('Origine', _originController),
                _buildNameField('Vaccin', _vaccineController),
                _buildEmplacementField(),
                const SizedBox(height: 20),
                Center(
                  child: CustomButton(
                    answerText: 'Ajouter',
                    onTap: _submitCattle,
                    icon: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNameField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? 'Veuillez entrer $label' : null,
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
          border: const OutlineInputBorder(),
        ),
        readOnly: true,
        onTap: () => _selectDate(controller),
        validator: (value) =>
            value!.isEmpty ? 'Veuillez sélectionner une date' : null,
      ),
    );
  }

  Widget _buildRadioField(
      String label, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Row(
            children: options.map((option) {
              return Expanded(
                child: ListTile(
                  title: Text(option),
                  leading: Radio<String>(
                    value: option,
                    groupValue: label == 'Sexe' ? _gender : _typeRacial,
                    onChanged: onChanged,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmplacementField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdownField('Emplacement', ['Étable', 'Éclos'],
                (value) {
              setState(() {
                _emplacement = value!;
              });
            }),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildNameField('Numéro', _emplacementNumberController),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
      String label, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) =>
            value == null ? 'Veuillez sélectionner $label' : null,
      ),
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(date);
      });
    }
  }

  Future<void> _submitCattle() async {
    if (!_formKey.currentState!.validate()) return;

    String category = _categoryController.text;
    String lightIndicator = 'off';
    String state = 'Good';

    var selectedDayOfArrival = _dayOfArrivalController.text;
    var selectedDayOfArrivalObject =
        DateFormat('yyyy-MM-dd').parse(selectedDayOfArrival);
    var timestampDayOfArrival = Timestamp.fromDate(selectedDayOfArrivalObject);

    var selectedDayOfBirth = _dayOfBirthController.text;
    var selectedDayOfBirthObject =
        DateFormat('yyyy-MM-dd').parse(selectedDayOfBirth);
    var timestampDayOfBirth = Timestamp.fromDate(selectedDayOfBirthObject);

    String emplacement = '$_emplacement ${_emplacementNumberController.text}';

    try {
      var user = auth.FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Utilisateur non authentifié';

      var cattleDocRef =
          await FirebaseFirestore.instance.collection('cattle').add({
        'category': category,
        'dayOfArrival': timestampDayOfArrival,
        'dayOfBirth': timestampDayOfBirth,
        'esp32': _esp32Controller.text,
        'lightIndicator': lightIndicator,
        'owner': FirebaseFirestore.instance.collection('users').doc(user.uid),
        'rfid': _rfidController.text,
        'state': state,
        'gender': _gender,
        'type racial': _typeRacial,
        'race': _raceController.text,
        'origin': _originController.text,
        'vaccine': _vaccineController.text.split(','),
        'emplacement': emplacement,
      });

      await cattleDocRef.collection('temperatures').add({
        'temperature': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bétail ajouté avec succès'),
          duration: Duration(seconds: 2),
        ),
      );

      widget.onCattleAdded?.call();

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de l\'ajout du bétail : $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
