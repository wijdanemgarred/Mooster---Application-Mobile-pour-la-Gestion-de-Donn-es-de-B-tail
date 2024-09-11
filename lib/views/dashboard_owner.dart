import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Mooster/views/notification_list.dart';
import '../model/cattle.dart';

class DashboardOwnerView extends StatefulWidget {
  final String userId;

  const DashboardOwnerView({super.key, required this.userId});

  @override
  State<DashboardOwnerView> createState() => _DashboardOwnerViewState();
}

class _DashboardOwnerViewState extends State<DashboardOwnerView> {
  late bool isUsersLoading;
  late bool isCattlesLoading;
  late bool isNotificationsLoading;
  late Map<String, int> userCategoriesCount;
  late Map<String, int> cattleCategoriesCount;
  int totalCattles = 0;
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    isUsersLoading = true;
    isCattlesLoading = true;
    isNotificationsLoading = true;
    userCategoriesCount = {};
    cattleCategoriesCount = {};
    fetchCattles();
    fetchNotifications();
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
        totalCattles = fetchedCattles.length;
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

  Future<void> fetchNotifications() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('user',
              isEqualTo: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId))
          .get();

      setState(() {
        notificationCount = snapshot.docs.length;
        isNotificationsLoading = false;
      });

      print('Fetched notifications count: $notificationCount');
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        isNotificationsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        // Customize your app bar here
      ),
      body: Column(
        children: [
          _buildCountWidgets(),
          Expanded(
            child: PageView(
              scrollDirection: Axis.vertical,
              children: [
                _buildPageContent("", _buildCattleCategoryPieChart()),
                // Add more pages with charts here
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountWidgets() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCountWidget(
            imagePath: 'assets/images/cow_icon.png',
            count: totalCattles,
            label: 'Total Cattles',
            onTap: () {},
          ),
          _buildCountWidget(
            imagePath: 'assets/images/bell.png',
            count: notificationCount,
            label: 'Notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationList(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCountWidget({
    required String imagePath,
    required int count,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200], // Light grey background
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              width: 70,
              height: 50,
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(String title, Widget chartWidget) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          chartWidget,
        ],
      ),
    );
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
                centerSpaceRadius: 50,
                // add more customization for pie chart here
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

    return Column(
      children: legendItems,
    );
  }
}
