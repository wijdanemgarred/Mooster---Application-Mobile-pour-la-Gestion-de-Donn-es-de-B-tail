// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:Mooster/views/profil_detail_ownerview.dart';
import '../model/user.dart';
import '../tiles/user_tile.dart';
import '../components/custom_search_bar.dart'; // Import the CustomSearchBar class

class UsersListView extends StatefulWidget {
  final String userId;

  final VoidCallback refreshUsersList;
  const UsersListView(
      {super.key, required this.userId, required this.refreshUsersList});

  @override
  State<UsersListView> createState() {
    return _UsersListViewState();
  }
}

class _UsersListViewState extends State<UsersListView> {
  List<User> usersList = [];
  bool isLoading = true;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void _onSearchChanged(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm.toLowerCase();
    });
  }

  // Generic filter list method
  List<T> _filterList<T>(List<T> list, bool Function(T) filterFunc) {
    if (_searchTerm.isEmpty) return list;
    return list.where(filterFunc).toList();
  }

  Future<void> fetchUsers() async {
    try {
      List<User> fetchedUsers = await User.fetchAllUsers();
      print('Fetched ${fetchedUsers.length} users');
      setState(() {
        usersList = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Apply filtering logic here
    List<User> filteredUsers = _filterList(
      usersList,
      (User u) =>
          u.name.toLowerCase().contains(_searchTerm) ||
          u.surname.toLowerCase().contains(_searchTerm) ||
          u.category.toLowerCase().contains(_searchTerm),
    );

    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomSearchBar(onSearchChanged: _onSearchChanged),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                print('Refreshing users list...');
                await fetchUsers();
                print('Users list refreshed.');
              },
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  return UserTile(
                    user: filteredUsers[index],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilOwnerView(
                              userId: filteredUsers[index].userId),
                        ),
                      );
                      print('Navigated back from profile view.');
                      widget.refreshUsersList();
                    },
                  );
                },
              ),
            ),
    );
  }
}
