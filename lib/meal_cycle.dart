import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MealPlanDay {
  final String lunch;
  final String dinner;
  final double cost;
  const MealPlanDay({required this.lunch, required this.dinner, required this.cost});
}

// Edit these 3 lines any time to change your fixed rotation.
const List<MealPlanDay> kMealCycle = [
  MealPlanDay(lunch: 'Veg Biryani (₹63)', dinner: 'Paneer Masala (₹86) + 3 Chapatis (₹21)', cost: 210),
  MealPlanDay(lunch: 'Soyabean Biryani (₹84)', dinner: 'Chana Masala (₹69) + 4 Chapatis (₹28)', cost: 221),
  MealPlanDay(lunch: 'Aloo Jeera (₹53) + 2 Chapatis (₹14)', dinner: 'Mushroom Fried Rice (₹95)', cost: 202),
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
  static const _activationKey = 'meal_activation_by_date'; // date -> dayIndex
  static const _extraKey = 'meal_extra_by_date'; // date -> List<ExtraExpense>

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Map<String, int> _activation = {};
  Map<String, List<ExtraExpense>> _extras = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final actRaw = prefs.getString(_activationKey);
    final extRaw = prefs.getString(_extraKey);
    setState(() {
      if (actRaw != null) {
        final m = jsonDecode(actRaw) as Map<String, dynamic>;
        _activation = m.map((k, v) => MapEntry(k, v as int));
      }
      if (extRaw != null) {
        final m = jsonDecode(extRaw) as Map<String, dynamic>;
        _extras = m.map((k, v) => MapEntry(
            k, (v as List).map((e) => ExtraExpense.fromJson(e)).toList()));
      }
    });
  }

  Future<void> _saveActivation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activationKey, jsonEncode(_activation));
  }

  Future<void> _saveExtras() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _extraKey, jsonEncode(_extras.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()))));
  }

  void _toggleDay(int dayIndex) {
    setState(() {
      if (_activation[_today] == dayIndex) {
        _activation.remove(_today); // untick = deactivate
      } else {
        _activation[_today] = dayIndex; // only one active per day
      }
    });
    _saveActivation();
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

  double get _todayCycleCost {
    final active = _activation[_today];
    return active != null ? kMealCycle[active].cost : 0;
  }

  double get _todayExtraCost =>
      (_extras[_today] ?? []).fold(0.0, (s, e) => s + e.cost);

  double get _todaySpent => _todayCycleCost + _todayExtraCost;

  @override
  Widget build(BuildContext context) {
    final remaining = kDailyBudget - _todaySpent;
    final extras = _extras[_today] ?? [];
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
          const SizedBox(height: 12),
          const Text('Activate today\'s plan (tap the tick):', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...List.generate(kMealCycle.length, (i) {
            final day = kMealCycle[i];
            final active = _activation[_today] == i;
            return Card(
              color: active ? Colors.indigo.withOpacity(0.25) : null,
              child: ListTile(
                leading: Checkbox(value: active, onChanged: (_) => _toggleDay(i)),
                title: Text('Day ${i + 1}: ${day.lunch}'),
                subtitle: Text('${day.dinner}\nCost: ₹${day.cost.toStringAsFixed(0)}'),
                isThreeLine: true,
              ),
            );
          }),
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
          Text('Note: this cycle resets daily — you must tick a plan again each day it applies.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }
}
