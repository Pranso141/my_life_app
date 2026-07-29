import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class FoodEntry {
  String name;
  double cost;
  String date; // yyyy-MM-dd

  FoodEntry({required this.name, required this.cost, required this.date});

  Map<String, dynamic> toJson() => {'name': name, 'cost': cost, 'date': date};

  factory FoodEntry.fromJson(Map<String, dynamic> json) => FoodEntry(
        name: json['name'],
        cost: (json['cost'] as num).toDouble(),
        date: json['date'],
      );
}

class FoodTodayScreen extends StatefulWidget {
  const FoodTodayScreen({super.key});

  @override
  State<FoodTodayScreen> createState() => _FoodTodayScreenState();
}

class _FoodTodayScreenState extends State<FoodTodayScreen> {
  List<FoodEntry> _entries = [];
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  static const _storageKey = 'food_entries';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      setState(() {
        _entries = list.map((e) => FoodEntry.fromJson(e)).toList();
      });
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _storageKey, jsonEncode(_entries.map((e) => e.toJson()).toList()));
  }

  List<FoodEntry> get _todaysEntries =>
      _entries.where((e) => e.date == _selectedDate).toList();

  double get _total =>
      _todaysEntries.fold(0.0, (sum, e) => sum + e.cost);

  void _addEntry() {
    final nameController = TextEditingController();
    final costController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Food / Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item name'),
            ),
            TextField(
              controller: costController,
              decoration: const InputDecoration(labelText: 'Cost'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final cost = double.tryParse(costController.text.trim()) ?? 0;
              if (name.isNotEmpty) {
                setState(() {
                  _entries.add(FoodEntry(
                      name: name, cost: cost, date: _selectedDate));
                });
                _save();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteEntry(FoodEntry entry) {
    setState(() {
      _entries.remove(entry);
    });
    _save();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(_selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = _todaysEntries;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDate),
                ),
                Text(
                  'Total: ₹${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('No entries for this day yet.'))
                : SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Item')),
                        DataColumn(label: Text('Cost')),
                        DataColumn(label: Text('')),
                      ],
                      rows: entries
                          .map(
                            (e) => DataRow(cells: [
                              DataCell(Text(e.name)),
                              DataCell(Text('₹${e.cost.toStringAsFixed(2)}')),
                              DataCell(IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteEntry(e),
                              )),
                            ]),
                          )
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}
