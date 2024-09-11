// ignore_for_file: avoid_print

import 'package:Mooster/views/cattle_list_view.dart';
import 'package:flutter/material.dart';
import 'package:Mooster/add/add_cattle.dart';
import '../add/add_user.dart';
import '../login/login_page.dart';
import '../views/dashboard_view.dart';
import '../views/users_list_view.dart';

class HomePageAdmin extends StatefulWidget {
  final int initialPage;
  final String userId;

  const HomePageAdmin(
      {super.key, required this.initialPage, required this.userId});

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  int _selectedIndex = 0;
  String _searchTerm = '';
  final List<String> _titles = ['Dashboard', 'Livestock', 'Users', 'Logout'];

  List<dynamic> allItems = [];
  List<dynamic> filteredItems = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialPage;
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      // Assuming the logout is the last item
      _logout();
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LogInScreen()),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchTerm = value.toLowerCase();
      if (_searchTerm.isEmpty) {
        filteredItems = allItems;
      } else {
        filteredItems = allItems
            .where((item) => item.name.toLowerCase().contains(_searchTerm))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: ValueKey(_selectedIndex),
        title: Text(_titles[_selectedIndex]),
      ),
      body: _buildPageContent(_selectedIndex),
      bottomNavigationBar: buildBottomNavigationBar(),
      floatingActionButton: buildFloatingActionButton(),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/dashboard_icon.png',
              width: 35, height: 35),
          activeIcon: Image.asset('assets/images/dashboard_icon.png',
              width: 40, height: 40),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/livestock_icon.png',
              width: 35, height: 35),
          activeIcon: Image.asset('assets/images/livestock_icon.png',
              width: 40, height: 40),
          label: 'Livestock',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/family_icon.png',
              width: 35, height: 35),
          activeIcon: Image.asset('assets/images/family_icon.png',
              width: 40, height: 40),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/out.png', width: 35, height: 35),
          activeIcon:
              Image.asset('assets/images/out.png', width: 40, height: 40),
          label: 'Logout',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue,
      onTap: _onItemTapped,
    );
  }

  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return _buildDashboardView();
      case 1:
        return CattleListView(userId: widget.userId);
      case 2:
        return UsersListView(
            userId: widget.userId, refreshUsersList: _refreshUsersList);
      default:
        return const Center(child: Text('Error: Unknown index'));
    }
  }

  Widget _buildDashboardView() {
    return const DashboardView();
  }

  Widget buildFloatingActionButton() {
    if (_selectedIndex == 1) {
      return FloatingActionButton(
        onPressed: () {
          print('Add action for add cattle');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddCattle(onCattleAdded: _refreshCattlesList),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      );
    }
    if (_selectedIndex == 2) {
      return FloatingActionButton(
        onPressed: () {
          print('Navigating to AddUser...');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddUser(onUserAdded: _refreshUsersList),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      );
    }
    return const SizedBox();
  }

  void _refreshUsersList() {
    print('Refreshing user list...');
    setState(() {});
    print('User list refreshed.');
  }

  void _refreshCattlesList() {
    print('Refreshing cattle list...');
    setState(() {});
    print('cattle list refreshed.');
  }
}
