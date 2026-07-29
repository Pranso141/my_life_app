import 'package:flutter/material.dart';
import 'food_today.dart';
import 'work_todo.dart';
import 'semester_plans.dart';
import 'package:flutter/material.dart';
import 'meal_cycle.dart';
import 'recurring_expenses.dart';
import 'work_todo.dart';
import 'objectives.dart';
import 'monthly_food_summary.dart';
import 'monthly_expense_history.dart';

void main() {
  runApp(const DayLedgerApp());
}

class DayLedgerApp extends StatelessWidget {
  const DayLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DayLedger',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('DayLedger'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Food', icon: Icon(Icons.restaurant)),
            Tab(text: 'Recurring Expenses', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Work To Do', icon: Icon(Icons.checklist)),
            Tab(text: 'Objectives', icon: Icon(Icons.school)),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('DayLedger', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Monthly Food Spend'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MonthlyFoodSummaryScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Monthly Expense History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MonthlyExpenseHistoryScreen()));
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MealCycleScreen(),
          RecurringExpensesScreen(),
          WorkTodoScreen(),
          ObjectivesScreen(),
        ],
      ),
    );
  }
}

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
