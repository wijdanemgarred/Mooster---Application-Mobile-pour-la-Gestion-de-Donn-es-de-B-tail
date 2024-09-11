import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user.dart';
import '../model/cattle.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late bool isUsersLoading;
  late bool isCattlesLoading;
  late Map<String, int> userCategoriesCount;
  late Map<String, int> cattleCategoriesCount;

  @override
  void initState() {
    super.initState();
    isUsersLoading = true;
    isCattlesLoading = true;
    userCategoriesCount = {};
    cattleCategoriesCount = {};
    fetchUsers();
    fetchCattles();
  }

  Future<void> fetchUsers() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      List<User> fetchedUsers =
          snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();

      Map<String, int> categoriesCount = {};
      for (var user in fetchedUsers) {
        categoriesCount[user.category] =
            (categoriesCount[user.category] ?? 0) + 1;
      }

      setState(() {
        userCategoriesCount = categoriesCount;
        isUsersLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        isUsersLoading = false;
      });
    }
  }

  Future<void> fetchCattles() async {
    try {
      List<Cattle> fetchedCattles = await Cattle.fetchAllCattles();

      Map<String, int> categoriesCount = {};
      for (var cattle in fetchedCattles) {
        categoriesCount[cattle.state] =
            (categoriesCount[cattle.state] ?? 0) + 1;
      }

      setState(() {
        cattleCategoriesCount = categoriesCount;
        isCattlesLoading = false;
      });

      print('Fetched cattle data: $cattleCategoriesCount');
    } catch (e) {
      print('Error fetching cattles: $e');
      setState(() {
        isCattlesLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PageView(
        scrollDirection: Axis.vertical,
        children: [
          _buildPageContent(
              "User Categories Distribution", _buildUserCategoryPieChart()),
          _buildPageContent(
              "Cattle Categories Distribution", _buildCattleCategoryPieChart()),
          // Add more pages with charts here
        ],
      ),
    );
  }

  Widget _buildPageContent(String title, Widget chartWidget) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          chartWidget,
        ],
      ),
    );
  }

  Widget _buildUserCategoryPieChart() {
    List<PieChartSectionData> sections =
        userCategoriesCount.entries.map((entry) {
      final color = Colors.primaries[
          userCategoriesCount.keys.toList().indexOf(entry.key) %
              Colors.primaries.length];
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '',
        color: color,
        radius: 60,
      );
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 0,
                centerSpaceRadius: 30,
              ),
            ),
          ),
        ),
        _buildLegend(userCategoriesCount),
      ],
    );
  }

  Widget _buildLegend(Map<String, int> categoriesCount) {
    List<Widget> legendItems = categoriesCount.entries.map((entry) {
      final color = Colors.primaries[
          categoriesCount.keys.toList().indexOf(entry.key) %
              Colors.primaries.length];
      return ListTile(
        leading: Icon(Icons.circle, color: color),
        title: Text('${entry.key}: ${entry.value}'),
      );
    }).toList();

    return Column(children: legendItems);
  }

  Widget _buildCattleCategoryPieChart() {
    Map<String, Color> colorMap = {
      'Good': Colors.green,
      'Sick': Colors.red,
      'On Treatment': Colors.yellow,
    };

    List<PieChartSectionData> sections =
        cattleCategoriesCount.entries.map((entry) {
      final color = colorMap[entry.key] ??
          Colors.grey; // Default color if state is unknown
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '',
        color: color,
        radius: 60,
      );
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 0,
                centerSpaceRadius: 30,
              ),
            ),
          ),
        ),
        _buildCattleLegend(),
      ],
    );
  }

  Widget _buildCattleLegend() {
    Map<String, Color> colorMap = {
      'Good': Colors.green,
      'Sick': Colors.red,
      'On Treatment': Colors.yellow,
    };

    List<Widget> legendItems = cattleCategoriesCount.entries.map((entry) {
      final color = colorMap[entry.key] ??
          Colors.grey; // Default color if state is unknown
      return ListTile(
        leading: Icon(Icons.circle, color: color),
        title: Text('${entry.key}: ${entry.value}'),
      );
    }).toList();

    return Column(children: legendItems);
  }
}
