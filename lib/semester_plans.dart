import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Goal {
  String text;
  String status; // Not Started, In Progress, Done

  Goal({required this.text, this.status = 'Not Started'});

  Map<String, dynamic> toJson() => {'text': text, 'status': status};

  factory Goal.fromJson(Map<String, dynamic> json) =>
      Goal(text: json['text'], status: json['status'] ?? 'Not Started');
}

class SemesterPlansScreen extends StatefulWidget {
  const SemesterPlansScreen({super.key});

  @override
  State<SemesterPlansScreen> createState() => _SemesterPlansScreenState();
}

class _SemesterPlansScreenState extends State<SemesterPlansScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _semesters = ['Sem 5', 'Sem 6', 'Sem 7', 'Sem 8'];
  Map<String, List<Goal>> _plans = {};
  late TabController _subTabController;
  static const _storageKey = 'semester_plans';

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: _semesters.length, vsync: this);
    _plans = {for (var s in _semesters) s: []};
    _load();
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        _plans = {
          for (var s in _semesters)
            s: (map[s] as List? ?? [])
                .map((e) => Goal.fromJson(e))
                .toList()
                .cast<Goal>()
        };
      });
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      for (var s in _semesters)
        s: _plans[s]!.map((g) => g.toJson()).toList()
    };
    await prefs.setString(_storageKey, jsonEncode(map));
  }

  void _addGoal(String semester) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Goal for $semester'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Goal'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() => _plans[semester]!.add(Goal(text: text)));
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

  void _updateStatus(String semester, int index, String status) {
    setState(() => _plans[semester]![index].status = status);
    _save();
  }

  void _deleteGoal(String semester, int index) {
    setState(() => _plans[semester]!.removeAt(index));
    _save();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Done':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _subTabController,
            isScrollable: true,
            tabs: _semesters.map((s) => Tab(text: s)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _subTabController,
              children: _semesters.map((semester) {
                final goals = _plans[semester] ?? [];
                return goals.isEmpty
                    ? const Center(child: Text('No goals added yet.'))
                    : SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Goal')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('')),
                          ],
                          rows: List.generate(goals.length, (index) {
                            final g = goals[index];
                            return DataRow(cells: [
                              DataCell(Text(g.text)),
                              DataCell(
                                DropdownButton<String>(
                                  value: g.status,
                                  items: const [
                                    'Not Started',
                                    'In Progress',
                                    'Done'
                                  ]
                                      .map((s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(
                                              s,
                                              style: TextStyle(
                                                  color: _statusColor(s)),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      _updateStatus(semester, index, v);
                                    }
                                  },
                                ),
                              ),
                              DataCell(IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    _deleteGoal(semester, index),
                              )),
                            ]);
                          }),
                        ),
                      );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addGoal(_semesters[_subTabController.index]),
        child: const Icon(Icons.add),
      ),
    );
  }
}
