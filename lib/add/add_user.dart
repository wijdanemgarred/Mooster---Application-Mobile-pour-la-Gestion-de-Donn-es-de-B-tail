// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../model/user.dart' as project_user;
import '../components/custom_button.dart';

class AddUser extends StatefulWidget {
  final VoidCallback? onUserAdded;
  const AddUser({super.key, this.onUserAdded});

  @override
  State<AddUser> createState() {
    return _AddUserState();
  }
}

class _AddUserState extends State<AddUser> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedCategory = 'doctor';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNameField('Nom', _nomController),
                const SizedBox(height: 1),
                _buildNameField('Prenom', _prenomController),
                const SizedBox(height: 1),
                _buildNameField('Email', _emailController),
                const SizedBox(height: 1),
                _buildNameField('Phone Number', _phoneController),
                const SizedBox(height: 22),
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                _buildCategoryRadioList(),
                const SizedBox(height: 20),
                Center(
                  child: CustomButton(
                    answerText: 'Submit User',
                    onTap: _submitUser,
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

  Widget _buildNameField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildCategoryRadioList() {
    return Column(
      children: ['doctor', 'owner']
          .map((category) => RadioListTile<String>(
                title: Text(category, style: const TextStyle(fontSize: 16)),
                value: category,
                dense: true,
                groupValue: _selectedCategory,
                onChanged: (newValue) =>
                    setState(() => _selectedCategory = newValue!),
              ))
          .toList(),
    );
  }

  Future<void> _submitUser() async {
    if (!_formKey.currentState!.validate()) return;

    String email = _emailController.text.trim();
    String password = '123456';

    try {
      await project_user.User.addUser(
        email,
        password,
        _nomController.text,
        _prenomController.text,
        _selectedCategory,
        _phoneController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User successfully added'),
          duration: Duration(seconds: 2),
        ),
      );

      print('Calling onUserAdded callback...');
      widget.onUserAdded?.call();
      print('onUserAdded callback called.');

      print('Popping navigation stack...');
      Navigator.of(context).pop();
      print('Navigation stack popped.');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add user: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
