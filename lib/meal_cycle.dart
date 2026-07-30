import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class FoodOption {
  final String name;
  final double cost;
  const FoodOption({required this.name, required this.cost});
}

// Edit these lists any time to add/remove/rename meal combos or fix prices.
const List<FoodOption> kLunchOptions = [
  FoodOption(name: 'Veg Biryani', cost: 63),
  FoodOption(name: 'Soyabean Biryani', cost: 84),
  FoodOption(name: 'Aloo Jeera + 2 Chapatis', cost: 67),
];

const List<FoodOption> kDinnerOptions = [
  FoodOption(name: 'Paneer Masala + 3 Chapatis', cost: 107),
  FoodOption(name: 'Chana Masala + 4 Chapatis', cost: 97),
  FoodOption(name: 'Mushroom Fried Rice', cost: 95),
];

const double kDailyBudget = 250;

class ExtraExpense {
  String name;
  double cost;
  ExtraExpense({required this.name, required this.cost});
  Map<String, dynamic> toJson() => {'name': name, 'cost': cost};
  factory ExtraExpense.fromJson(Map<String, dynamic> j) =>
      ExtraExpense(name: j['name'], cost: (j['cost'] as num).toDouble());
}

class MealCycleScreen extends StatefulWidget {
  const MealCycleScreen({super.key});
  @override
  State<MealCycleScreen> createState() => _MealCycleScreenState();
}

class _MealCycleScreenState extends State<MealCycleScreen> {
  static const _ticksKey = 'food_ticks_by_date'; // date -> List<foodName>
  static const _extraKey = 'meal_extra_by_date'; // date -> List<ExtraExpense>

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Map<String, List<String>> _ticks = {};
  Map<String, List<ExtraExpense>> _extras = {};

  static List<FoodOption> get _allOptions => [...kLunchOptions, ...kDinnerOptions];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ticksRaw = prefs.getString(_ticksKey);
    final extRaw = prefs.getString(_extraKey);
    setState(() {
      if (ticksRaw != null) {
        final m = jsonDecode(ticksRaw) as Map<String, dynamic>;
        _ticks = m.map((k, v) => MapEntry(k, (v as List).cast<String>()));
      }
      if (extRaw != null) {
        final m = jsonDecode(extRaw) as Map<String, dynamic>;
        _extras = m.map((k, v) => MapEntry(
            k, (v as List).map((e) => ExtraExpense.fromJson(e)).toList()));
      }
    });
  }

  Future<void> _saveTicks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ticksKey, jsonEncode(_ticks));
  }

  Future<void> _saveExtras() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _extraKey, jsonEncode(_extras.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()))));
  }

  void _toggleFood(String name) {
    setState(() {
      final todayList = _ticks.putIfAbsent(_today, () => []);
      if (todayList.contains(name)) {
        todayList.remove(name);
      } else {
        todayList.add(name);
      }
    });
    _saveTicks();
  }

  void _addExtra() {
    final nameCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Extra Expense (Today)'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'Cost'), keyboardType: TextInputType.number),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final cost = double.tryParse(costCtrl.text.trim()) ?? 0;
              if (name.isNotEmpty) {
                setState(() {
                  _extras.putIfAbsent(_today, () => []).add(ExtraExpense(name: name, cost: cost));
                });
                _saveExtras();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteExtra(int index) {
    setState(() => _extras[_today]!.removeAt(index));
    _saveExtras();
  }

  double get _todayFoodCost {
    final ticked = _ticks[_today] ?? [];
    double total = 0;
    for (final name in ticked) {
      final match = _allOptions.where((o) => o.name == name);
      if (match.isNotEmpty) total += match.first.cost;
    }
    return total;
  }

  double get _todayExtraCost => (_extras[_today] ?? []).fold(0.0, (s, e) => s + e.cost);

  double get _todaySpent => _todayFoodCost + _todayExtraCost;

  Widget _optionSection(String title, List<FoodOption> options, List<String> ticked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4, left: 4),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
        ),
        ...options.map((option) {
          final checked = ticked.contains(option.name);
          return Card(
            color: checked ? Colors.indigo.withOpacity(0.25) : null,
            child: CheckboxListTile(
              value: checked,
              onChanged: (_) => _toggleFood(option.name),
              title: Text(option.name),
              secondary: Text('₹${option.cost.toStringAsFixed(0)}'),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = kDailyBudget - _todaySpent;
    final extras = _extras[_today] ?? [];
    final ticked = _ticks[_today] ?? [];

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: remaining < 0 ? Colors.red.shade900 : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Budget: ₹${kDailyBudget.toStringAsFixed(0)}/day'),
                  Text('Spent: ₹${_todaySpent.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(remaining >= 0 ? 'Left: ₹${remaining.toStringAsFixed(0)}' : 'Over by ₹${(-remaining).toStringAsFixed(0)}'),
                ],
              ),
            ),
          ),
          _optionSection('Lunch options — tick what you had', kLunchOptions, ticked),
          _optionSection('Dinner options — tick what you had', kDinnerOptions, ticked),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Extra expenses today', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton.icon(onPressed: _addExtra, icon: const Icon(Icons.add), label: const Text('Add')),
            ],
          ),
          if (extras.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('None yet.')),
          ...List.generate(extras.length, (i) => ListTile(
                title: Text(extras[i].name),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('₹${extras[i].cost.toStringAsFixed(0)}'),
                  IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteExtra(i)),
                ]),
              )),
          const SizedBox(height: 8),
          Text('Note: ticks reset daily — tick again each day it applies.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }
}
