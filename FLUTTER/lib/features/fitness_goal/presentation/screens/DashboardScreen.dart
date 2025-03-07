import 'package:fitness4life/features/fitness_goal/presentation/screens/Goal/GoalScreen.dart';
import 'package:flutter/material.dart';



class DashboardScreen extends StatefulWidget {
  final int initialTabIndex;

  const DashboardScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3,
        vsync: this,
        initialIndex: widget.initialTabIndex,

    ); // 4 tab items
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Information Goal',
          style: TextStyle(color: Colors.white),  // Title màu trắng
        ),
        backgroundColor: const Color(0xFFB00020),  // Màu nền đen cho AppBar
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Goals'),
            Tab(text: 'Progress'),
            //Tab(text: 'Discover'),
          ],
          labelColor: Colors.orange,  // Màu chữ của tab
          indicatorColor: Colors.orange,  // Màu chỉ dưới tab
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          GoalScreen(),
          _buildLogTab(),
          _buildDiscoverTab(),
        ],
      ),
    );
  }

  // Function to build Dashboard content
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Favorite Calories Section
          const Text(
            'Favorites',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF2D2F41), // Dark background color
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataRow('CALORIES', '1.850 UNDER'),
                SizedBox(height: 16),
                _buildMacronutrientsRow(),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Streak & Weight Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStreakRow(),
              _buildWeightRow(),
            ],
          ),
          SizedBox(height: 20),

          // Button at the bottom
          Center(
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6F00), // Orange color for button
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build other tabs (Log, Goals, Discover)
  Widget _buildLogTab() {
    return Center(
      child: Text(
        'Log Tab Content',
        style: TextStyle(fontSize: 20, color: Colors.red),
      ),
    );
  }

  Widget _buildGoalsTab() {
    return const Center(
      child: Text(
        'Goals Tab Content',
        style: TextStyle(fontSize: 20, color: Colors.red),
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return Center(
      child: Text(
        'Discover Tab Content',
        style: TextStyle(fontSize: 20, color: Colors.red),
      ),
    );
  }

  // Helper Functions for each Row (Data Rows)
  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMacronutrientsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MACRONUTRIENTS',
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDataRow('Fat', '0%'),
            _buildDataRow('Carbs', '0%'),
            _buildDataRow('Protein', '0%'),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STREAK',
          style: TextStyle(color: Colors.red),
        ),
        Row(
          children: List.generate(7, (index) => Icon(Icons.circle, size: 10, color: Colors.red)),
        ),
        SizedBox(height: 5),
        Text(
          '0 Days',
          style: TextStyle(color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildWeightRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WEIGHT',
          style: TextStyle(color: Colors.red),
        ),
        Row(
          children: [
            Icon(Icons.arrow_downward, color: Colors.red),
            SizedBox(width: 5),
            Text(
              '73 kg',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 5),
        Text(
          '10 Day Avg',
          style: TextStyle(color: Colors.red),
        ),
      ],
    );
  }
}
