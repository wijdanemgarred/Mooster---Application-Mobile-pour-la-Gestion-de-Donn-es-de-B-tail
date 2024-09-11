import 'package:flutter/material.dart';
import 'package:Mooster/components/custom_button.dart';
import 'package:Mooster/model/user.dart';
import '../model/cattle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../model/checkup.dart';

class AddCheckup extends StatefulWidget {
  final String cattleId;
  final VoidCallback? onCheckupAdded;

  const AddCheckup({super.key, required this.cattleId, this.onCheckupAdded});

  @override
  State<AddCheckup> createState() => _AddCheckupState();
}

class _AddCheckupState extends State<AddCheckup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _observationController = TextEditingController();
  final TextEditingController _vaccinController = TextEditingController();
  final TextEditingController _medsController = TextEditingController();
  final List<String> _medications = [];
  bool isPregnant = false;
  DateTime? pregnancyDate;

  @override
  void dispose() {
    _observationController.dispose();
    _vaccinController.dispose();
    _medsController.dispose();
    super.dispose();
  }

  Future<void> _addCheckup() async {
    if (_formKey.currentState!.validate()) {
      final auth.User? currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun utilisateur connecté trouvé')),
        );
        return;
      }

      final DocumentReference cattleRef =
          FirebaseFirestore.instance.collection('cattle').doc(widget.cattleId);

      final checkup = Checkup(
        meds: _medications,
        observation: _observationController.text,
        timestamp: DateTime.now(),
        vaccin: _vaccinController.text,
        cattle: Cattle.fromFirestore(await cattleRef.get()),
        doctor: await User.fetchUserById(currentUser.uid),
      );

      await FirebaseFirestore.instance.collection('checkups').add({
        'meds': checkup.meds,
        'observation': checkup.observation,
        'timestamp': Timestamp.fromDate(checkup.timestamp),
        'vaccin': checkup.vaccin,
        'cattle': cattleRef,
        'doctor':
            FirebaseFirestore.instance.collection('users').doc(currentUser.uid),
        'isPregnant': isPregnant,
        'pregnancyDate':
            pregnancyDate != null ? Timestamp.fromDate(pregnancyDate!) : null,
      });

      // Update the cattle's pregnancy status if it is pregnant
      if (isPregnant && pregnancyDate != null) {
        await cattleRef.update({
          'isPregnant': isPregnant,
          'pregnancyDate': pregnancyDate,
        });
      }

      // Mettre à jour la liste des vaccins du bétail si un vaccin est ajouté
      if (_vaccinController.text.isNotEmpty) {
        await cattleRef.update({
          'vaccine': FieldValue.arrayUnion([_vaccinController.text])
        });
      }

      widget.onCheckupAdded?.call();
      Navigator.pop(context);
    }
  }

  void _addMedication(String medication) {
    setState(() {
      if (!_medications.contains(medication.trim())) {
        _medications.add(medication.trim());
        _medsController.clear(); // Clear the text field after adding medication
      }
    });
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un bilan de santé')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _observationController,
                  decoration: InputDecoration(
                    labelText: 'Observation',
                    hintText: 'Décrivez l\'état de santé actuel',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.note),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir une observation';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vaccinController,
                  decoration: InputDecoration(
                    labelText: 'Vaccin (Optionnel)',
                    hintText: 'Ajoutez un vaccin si nécessaire',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.vaccines),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _medsController,
                        decoration: InputDecoration(
                          labelText: 'Médicament',
                          hintText: 'Entrez le nom du médicament',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.medical_services),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.blue),
                      onPressed: () {
                        if (_medsController.text.trim().isNotEmpty) {
                          _addMedication(_medsController.text.trim());
                        }
                      },
                    ),
                  ],
                ),
                if (_medications.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _medications
                        .asMap()
                        .entries
                        .map((entry) => Chip(
                              label: Text(entry.value),
                              deleteIcon: const Icon(Icons.clear),
                              onDeleted: () {
                                _removeMedication(entry.key);
                              },
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Est-elle enceinte?',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: isPregnant,
                          onChanged: (value) {
                            setState(() {
                              isPregnant = value ?? false;
                            });
                          },
                        ),
                        const Text('Oui'),
                        Radio<bool>(
                          value: false,
                          groupValue: isPregnant,
                          onChanged: (value) {
                            setState(() {
                              isPregnant = value ?? false;
                            });
                          },
                        ),
                        const Text('Non'),
                      ],
                    ),
                    if (isPregnant) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Date de Gestation',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: pregnancyDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              pregnancyDate = selectedDate;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            pregnancyDate != null
                                ? '${pregnancyDate!.day}/${pregnancyDate!.month}/${pregnancyDate!.year}'
                                : 'Sélectionner une date',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                CustomButton(
                  answerText: 'Ajouter le bilan',
                  onTap: _addCheckup,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
