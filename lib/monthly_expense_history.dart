import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonthlyExpenseHistoryScreen extends StatefulWidget {
  const MonthlyExpenseHistoryScreen({super.key});
  @override
  State<MonthlyExpenseHistoryScreen> createState() => _MonthlyExpenseHistoryScreenState();
}

class _MonthlyExpenseHistoryScreenState extends State<MonthlyExpenseHistoryScreen> {
  Map<String, double> _monthTotals = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('recurring_expenses_by_month');
    final Map<String, double> totals = {};
    if (raw != null) {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      m.forEach((month, items) {
        final map = items as Map<String, dynamic>;
        totals[month] = map.values.fold(0.0, (s, v) => s + (v as num).toDouble());
      });
    }
    setState(() {
      _monthTotals = totals;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final months = _monthTotals.keys.toList()..sort((a, b) => b.compareTo(a));
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Expense History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : months.isEmpty
              ? const Center(child: Text('No history yet.'))
              : ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (ctx, i) => ListTile(
                    title: Text(months[i]),
                    trailing: Text('₹${_monthTotals[months[i]]!.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
    );
  }
}
