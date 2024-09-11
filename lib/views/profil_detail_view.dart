import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../model/user.dart';
import '../components/custom_button.dart';

class ProfilView extends StatefulWidget {
  final String userId;

  const ProfilView({super.key, required this.userId});

  @override
  State<ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends State<ProfilView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isEditing = false;
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() => _isLoading = true);
    try {
      _user = await User.fetchUserById(widget.userId);
      _nameController.text = _user!.name;
      _surnameController.text = _user!.surname;
      _categoryController.text = _user!.category;
      _emailController.text =
          auth.FirebaseAuth.instance.currentUser?.email ?? 'Not Available';
    } catch (e) {
      _showSnackBar('Error fetching user: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // utility function  capitalize the first letter of string
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  ImageProvider getCategoryImage(String category) {
    switch (category.toLowerCase()) {
      case 'admin':
        return const AssetImage('assets/images/admin_man_icon.png');
      case 'owner':
        return const AssetImage('assets/images/owner_icon.png');
      case 'doctor':
        return const AssetImage('assets/images/veterinarian_icon.png');
      default:
        return const AssetImage('assets/images/default_icon.png');
    }
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await User.updateUserPassword(_newPasswordController.text);
        _showSnackBar('Password updated successfully');
      } catch (e) {
        _showSnackBar('Failed to update password: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('')),
        body: const Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: getCategoryImage(_user!.category),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 20),
              Text('${_capitalize(_user!.name)} ${_capitalize(_user!.surname)}',
                  style: Theme.of(context).textTheme.titleLarge),
              Text(_capitalize(_user!.category),
                  style: Theme.of(context).textTheme.bodyLarge),
              const Divider(),
              ListTile(
                title: const Text('Email'),
                subtitle: Text(_emailController.text),
              ),
              _isEditing
                  ? _buildPasswordChangeForm()
                  : _buildPasswordListTile(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordChangeForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildPasswordField('Current Password', _oldPasswordController),
            _buildPasswordField('New Password', _newPasswordController),
            _buildPasswordField('Confirm Password', _confirmPasswordController),
            const SizedBox(height: 20),
            CustomButton(
              answerText: 'Update Password',
              onTap: _updatePassword,
              icon: const Icon(Icons.update),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordListTile() {
    return ListTile(
      title: const Text('Password'),
      subtitle: const Text('********'),
      trailing: CustomButton(
        answerText: 'Change Password',
        onTap: () => setState(() => _isEditing = true),
        icon: const Icon(Icons.lock_open),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (label == 'Confirm Password' &&
            value != _newPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
