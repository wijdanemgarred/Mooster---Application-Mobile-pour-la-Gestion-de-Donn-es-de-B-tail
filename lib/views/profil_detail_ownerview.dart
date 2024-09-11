import 'package:flutter/material.dart';
import '../model/user.dart';

class ProfilOwnerView extends StatefulWidget {
  final String userId;

  const ProfilOwnerView({super.key, required this.userId});

  @override
  State<ProfilOwnerView> createState() => _ProfilOwnerViewState();
}

class _ProfilOwnerViewState extends State<ProfilOwnerView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final bool _isEditing = false;
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
      _emailController.text = _user!.email;
      _phoneController.text = _user!.phone;

      // Fetch email from Firebase Authentication
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
              ListTile(
                title: const Text('Phone Number'),
                subtitle: Text(_phoneController.text),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
