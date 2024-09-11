import 'package:flutter/material.dart';
import 'package:Mooster/views/profil_detail_ownerview.dart';
import '../model/user.dart';
import '../tiles/user_tile.dart';
import '../components/custom_search_bar.dart'; // Import the CustomSearchBar class

class UsersListOwnerView extends StatefulWidget {
  final String userId;

  final VoidCallback refreshUsersList;
  const UsersListOwnerView(
      {super.key, required this.userId, required this.refreshUsersList});

  @override
  State<UsersListOwnerView> createState() {
    return _UsersListOwnerViewState();
  }
}

class _UsersListOwnerViewState extends State<UsersListOwnerView> {
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

  Future<void> fetchUsers() async {
    try {
      List<User> fetchedUsers = await User.fetchAllUsers();
      print('Fetched ${fetchedUsers.length} users');
      setState(() {
        usersList = fetchedUsers
            .where((user) =>
                user.userId != widget.userId &&
                user.category.toLowerCase() != 'admin')
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  List<User> _filterList(List<User> list) {
    if (_searchTerm.isEmpty) return list;
    return list
        .where((user) =>
            user.name.toLowerCase().contains(_searchTerm) ||
            user.surname.toLowerCase().contains(_searchTerm) ||
            user.category.toLowerCase().contains(_searchTerm))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    List<User> filteredUsers = _filterList(usersList);

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
