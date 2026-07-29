import 'package:flutter/material.dart';
import 'food_today.dart';
import 'work_todo.dart';
import 'semester_plans.dart';

void main() {
  runApp(const MyLifeApp());
}

class MyLifeApp extends StatelessWidget {
  const MyLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Life',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Life'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Food Today', icon: Icon(Icons.restaurant)),
            Tab(text: 'Work To Do', icon: Icon(Icons.checklist)),
            Tab(text: 'Semester Plans', icon: Icon(Icons.school)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FoodTodayScreen(),
          WorkTodoScreen(),
          SemesterPlansScreen(),
        ],
      ),
    );
  }
}
