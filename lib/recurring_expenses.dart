import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class RecurringItem {
  final String category;
  final String name;
  final double defaultAmount;
  const RecurringItem({required this.category, required this.name, required this.defaultAmount});
}

// Edit this list any time to add/remove/rename recurring expenses or change defaults.
const List<RecurringItem> kRecurringItems = [
  RecurringItem(category: 'Housing & Utilities', name: 'Rent', defaultAmount: 8000),
  RecurringItem(category: 'Housing & Utilities', name: 'Maid', defaultAmount: 286),
  RecurringItem(category: 'Housing & Utilities', name: 'Electricity', defaultAmount: 350),
  RecurringItem(category: 'Housing & Utilities', name: 'Water Filter', defaultAmount: 76),
  RecurringItem(category: 'Housing & Utilities', name: 'Wi-Fi', defaultAmount: 233),
  RecurringItem(category: 'Housing & Utilities', name: 'Mobile Recharge', defaultAmount: 450),
  RecurringItem(category: 'Health & Wealth', name: 'Gym', defaultAmount: 1500),
  RecurringItem(category: 'Health & Wealth', name: 'SIP Investments', defaultAmount: 2500),
  RecurringItem(category: 'Lifestyle & Travel', name: 'Miscellaneous', defaultAmount: 500),
  RecurringItem(category: 'Lifestyle & Travel', name: 'Weekend Commute', defaultAmount: 720),
];

class RecurringExpensesScreen extends StatefulWidget {
  const RecurringExpensesScreen({super.key});
  @override
  State<RecurringExpensesScreen> createState() => _RecurringExpensesScreenState();
}

class _RecurringExpensesScreenState extends State<RecurringExpensesScreen> {
  static const _storageKey = 'recurring_expenses_by_month'; // monthKey -> {name: amount}
  Map<String, Map<String, double>> _byMonth = {};
  bool _loading = true;

  String get _currentMonthKey => DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    Map<String, Map<String, double>> data = {};
    if (raw != null) {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      data = m.map((k, v) => MapEntry(k, (v as Map<String, dynamic>).map((k2, v2) => MapEntry(k2, (v2 as num).toDouble()))));
    }
    // Auto-create current month using device clock, defaulting to last month's values if present, else defaults.
    if (!data.containsKey(_currentMonthKey)) {
      final months = data.keys.toList()..sort();
      final lastMonth = months.isNotEmpty ? data[months.last] : null;
      data[_currentMonthKey] = {
        for (final item in kRecurringItems) item.name: lastMonth?[item.name] ?? item.defaultAmount
      };
      await _saveAll(data);
    }
    setState(() {
      _byMonth = data;
      _loading = false;
    });
  }

  Future<void> _saveAll(Map<String, Map<String, double>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  void _editAmount(String name) {
    final current = _byMonth[_currentMonthKey]?[name] ?? 0;
    final ctrl = TextEditingController(text: current.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $name'),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (₹)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.trim());
              if (val != null) {
                setState(() => _byMonth[_currentMonthKey]![name] = val);
                _saveAll(_byMonth);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final current = _byMonth[_currentMonthKey] ?? {};
    final total = current.values.fold(0.0, (s, v) => s + v);
    final categories = kRecurringItems.map((e) => e.category).toSet().toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Month: $_currentMonthKey', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Total: ₹${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
          for (final cat in categories) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 4, left: 4),
              child: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
            ),
            ...kRecurringItems.where((i) => i.category == cat).map((item) {
              final amount = current[item.name] ?? item.defaultAmount;
              return Card(
                child: ListTile(
                  title: Text(item.name),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('₹${amount.toStringAsFixed(0)}'),
                    IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editAmount(item.name)),
                  ]),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
