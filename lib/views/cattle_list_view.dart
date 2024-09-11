import 'package:Mooster/views/cattle_detail_view_doctor.dart';
import 'package:flutter/material.dart';
import '../model/cattle.dart';
import '../tiles/cattle_tile.dart';
import 'cattle_detail_view.dart';
import '../model/user.dart'; // Import the user model

import '../components/custom_search_bar.dart'; // Import the CustomSearchBar class

class CattleListView extends StatefulWidget {
  final String userId;

  const CattleListView({super.key, required this.userId});

  @override
  State<CattleListView> createState() {
    return _CattleListViewState();
  }
}

class _CattleListViewState extends State<CattleListView> {
  List<Cattle> cattleListAll = []; // store fetched cattle data in list

  bool isLoading = true;
  String? userCategory; // Store the user category
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    fetchUser(widget.userId); // Fetch the user data
    fetchCattlesAll();
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

  Future<void> fetchUser(String userId) async {
    try {
      User user = await User.fetchUserById(userId);
      setState(() {
        userCategory = user.category; // Set the user category
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCattlesAll() async {
    try {
      List<Cattle> fetchedCattles = await Cattle.fetchAllCattles();
      setState(() {
        cattleListAll = fetchedCattles;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching cattle data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Apply filtering logic here
    List<Cattle> filteredCattles = _filterList(
      cattleListAll,
      (Cattle u) => u.rfid
          .toLowerCase()
          .contains(_searchTerm), //add other filters to ssearch
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
          : ListView.builder(
              itemCount: filteredCattles.length,
              itemBuilder: (context, index) {
                return CattleTile(
                  cattle: filteredCattles[index],
                  onTap: () async {
                    if (userCategory != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            if (userCategory == 'owner') {
                              return CattleDetailView(
                                  cattleId: filteredCattles[index].cattleId);
                            } else if (userCategory == 'doctor') {
                              return CattleDetailDoctorView(
                                  cattleId: filteredCattles[index].cattleId);
                            }
                            return CattleDetailView(
                                cattleId: filteredCattles[index]
                                    .cattleId); // Default to owner view
                          },
                        ),
                      );
                    }
                    fetchCattlesAll();
                  },
                  userCategory:
                      userCategory ?? '', // Pass userCategory to CattleTile
                );
              },
            ),
    );
  }
}
