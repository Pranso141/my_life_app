import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'meal_cycle.dart';

class MonthlyFoodSummaryScreen extends StatefulWidget {
  const MonthlyFoodSummaryScreen({super.key});
  @override
  State<MonthlyFoodSummaryScreen> createState() => _MonthlyFoodSummaryScreenState();
}

class _MonthlyFoodSummaryScreenState extends State<MonthlyFoodSummaryScreen> {
  Map<String, double> _dailyTotals = {}; // date -> total spend
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final actRaw = prefs.getString('meal_activation_by_date');
    final extRaw = prefs.getString('meal_extra_by_date');
    final Map<String, int> activation = actRaw != null
        ? (jsonDecode(actRaw) as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int))
        : {};
    final Map<String, List<dynamic>> extras = extRaw != null
        ? (jsonDecode(extRaw) as Map<String, dynamic>).map((k, v) => MapEntry(k, v as List<dynamic>))
        : {};

    final Map<String, double> totals = {};
    final allDates = <String>{...activation.keys, ...extras.keys};
    for (final date in allDates) {
      double total = 0;
      final dayIndex = activation[date];
      if (dayIndex != null) total += kMealCycle[dayIndex].cost;
      final ex = extras[date] ?? [];
      for (final e in ex) {
        total += (e['cost'] as num).toDouble();
      }
      totals[date] = total;
    }
    setState(() {
      _dailyTotals = totals;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonthPrefix = DateFormat('yyyy-MM').format(now);
    final entries = _dailyTotals.entries.where((e) => e.key.startsWith(currentMonthPrefix)).toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final monthTotal = entries.fold(0.0, (s, e) => s + e.value);

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Food Spend')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('This month\'s total: ₹${monthTotal.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? const Center(child: Text('No food spend logged this month yet.'))
                      : ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (ctx, i) {
                            final e = entries[i];
                            final over = e.value > kDailyBudget;
                            return ListTile(
                              title: Text(e.key),
                              trailing: Text('₹${e.value.toStringAsFixed(0)}',
                                  style: TextStyle(color: over ? Colors.redAccent : null, fontWeight: FontWeight.bold)),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
