import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkItem {
  String title;
  bool done;

  WorkItem({required this.title, this.done = false});

  Map<String, dynamic> toJson() => {'title': title, 'done': done};

  factory WorkItem.fromJson(Map<String, dynamic> json) =>
      WorkItem(title: json['title'], done: json['done'] ?? false);
}

class WorkTodoScreen extends StatefulWidget {
  const WorkTodoScreen({super.key});

  @override
  State<WorkTodoScreen> createState() => _WorkTodoScreenState();
}

class _WorkTodoScreenState extends State<WorkTodoScreen> {
  List<WorkItem> _items = [];
  static const _storageKey = 'work_items';

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
        _items = list.map((e) => WorkItem.fromJson(e)).toList();
      });
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _storageKey, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  void _addItem() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Task'),
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
                setState(() => _items.add(WorkItem(title: text)));
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

  void _toggleDone(int index, bool? value) {
    setState(() => _items[index].done = value ?? false);
    _save();
  }

  void _deleteItem(int index) {
    setState(() => _items.removeAt(index));
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final pending = _items.where((e) => !e.done).length;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('$pending task(s) pending',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('No tasks yet. Tap + to add one.'))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (ctx, index) {
                      final item = _items[index];
                      return Dismissible(
                        key: ValueKey(item.hashCode.toString() + index.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteItem(index),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: CheckboxListTile(
                          value: item.done,
                          onChanged: (v) => _toggleDone(index, v),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              decoration: item.done
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.done ? Colors.grey : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
