import 'package:Mooster/views/cattle_list_view.dart';
import 'package:flutter/material.dart';
import 'package:Mooster/views/dashboard_owner.dart';
import 'package:Mooster/views/profil_detail_view.dart';
import '../login/login_page.dart';

class HomePageDoctor extends StatefulWidget {
  final int initialPage;
  final String userId;

  const HomePageDoctor(
      {super.key, required this.initialPage, required this.userId});

  @override
  State<HomePageDoctor> createState() => _HomePageDoctorState();
}

class _HomePageDoctorState extends State<HomePageDoctor> {
  int _selectedIndex = 0;
  String _searchTerm = '';
  final List<String> _titles = ['Dashboard', 'Livestock', 'Profil', 'Logout'];

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
          icon: Image.asset('assets/images/user_863817.png',
              width: 35, height: 35),
          activeIcon: Image.asset('assets/images/user_863817.png',
              width: 40, height: 40),
          label: 'Profil',
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
        return ProfilView(userId: widget.userId);
      default:
        return const Center(child: Text('Error: Unknown index'));
    }
  }

  Widget _buildDashboardView() {
    return DashboardOwnerView(userId: widget.userId);
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
